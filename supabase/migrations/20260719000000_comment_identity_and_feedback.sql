-- ========== COMMENT IDENTITY PRIVACY ==========
-- A per-user preference (surfaced in the app's Privacy screen) for whether
-- new top-level comments show the poster's real name/avatar or "Anonymous".
alter table public.profiles add column hide_identity_in_comments boolean not null default false;

-- Snapshot the preference onto each comment at post time -- so later toggling
-- the preference doesn't retroactively change how past comments render, and
-- so the client never has to be trusted to self-report anonymity correctly.
alter table public.comments add column is_anonymous boolean not null default false;

create or replace function public.set_comment_anonymity()
returns trigger as $$
begin
  -- Replies are always attributed -- "Official Reply" branding wouldn't make
  -- sense anonymous, and only the storyplugs@gmail.com account can reply anyway.
  if new.parent_id is not null then
    new.is_anonymous := false;
  else
    select coalesce(hide_identity_in_comments, false) into new.is_anonymous
    from public.profiles where id = new.user_id;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger set_comment_anonymity_trigger
  before insert on public.comments
  for each row execute function public.set_comment_anonymity();

-- ========== FEEDBACK ==========
create table public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  message text not null,
  created_at timestamptz not null default now()
);

create index feedback_user_idx on public.feedback (user_id);

alter table public.feedback enable row level security;

create policy "feedback_insert_own" on public.feedback
  for insert with check (auth.uid() = user_id);

create policy "feedback_select_own" on public.feedback
  for select using (auth.uid() = user_id);

create policy "feedback_select_admin" on public.feedback
  for select using (public.is_admin());
