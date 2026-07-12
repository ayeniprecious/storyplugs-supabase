-- Journal (premium): private reflection entries a user writes against a story's
-- reflection_question. story_title/reflection_question are snapshotted at write time
-- (not a live join to stories) for two reasons: reflection_question is admin-editable
-- text, so a live join would silently rewrite what an entry appears to have answered
-- if the wording later changes; and stories is RLS-gated to status='published', so a
-- live join would make the entry's context vanish if the story is later unpublished
-- even though the entry still belongs to the user.

create table public.journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  story_id uuid references public.stories(id) on delete set null,
  story_title text not null,
  reflection_question text not null,
  entry text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index journal_entries_user_idx on public.journal_entries (user_id, created_at desc);

create trigger set_journal_entries_updated_at
  before update on public.journal_entries
  for each row execute function public.set_updated_at();

alter table public.journal_entries enable row level security;

-- Split into separate policies rather than one shared `for all ... with check` --
-- a single shared with-check would re-validate the is_premium check on UPDATE too,
-- meaning a user who is later un-premiumed couldn't even edit/delete entries they
-- wrote while premium. Archive/Reader Mode don't retroactively take anything away
-- from a lapsed premium user; Journal shouldn't either. Only INSERT is premium-gated.
create policy "journal_entries_select_own" on public.journal_entries
  for select using (auth.uid() = user_id);

create policy "journal_entries_update_own" on public.journal_entries
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "journal_entries_delete_own" on public.journal_entries
  for delete using (auth.uid() = user_id);

create policy "journal_entries_insert_own_premium" on public.journal_entries
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.profiles where id = auth.uid() and is_premium)
  );

create policy "journal_entries_select_admin" on public.journal_entries
  for select using (public.is_admin());
