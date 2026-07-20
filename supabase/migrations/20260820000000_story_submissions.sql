-- Premium users can submit their own real stories for admin review; approved +
-- visible ones show in a dedicated "Community Stories" feed, kept separate from
-- the admin-authored stories table since these are user-attributed and need
-- independent moderation (status) and display (is_visible) controls -- an admin
-- can approve a submission but still keep it hidden, or unhide/rehide it later
-- without re-reviewing.

create table public.story_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  -- Snapshotted at submission time rather than joined live from profiles --
  -- profiles itself is locked to "read your own row" (see
  -- public_commenter_profiles for why comments needed a dedicated view for
  -- this exact problem), and a submission's byline doesn't need to track a
  -- later display-name change anyway.
  author_name text not null,
  title text not null,
  body text not null,
  category text references public.categories(slug),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  is_visible boolean not null default true,
  admin_note text,
  reviewed_by_admin_id uuid references public.admins(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create index story_submissions_user_idx on public.story_submissions (user_id, created_at desc);
create index story_submissions_public_idx on public.story_submissions (status, is_visible, created_at desc);

alter table public.story_submissions enable row level security;

-- Submitters see their own submissions regardless of status (so they can track
-- pending/rejected ones), and can only ever insert as themselves. Requiring
-- is_premium here (not just client-side gating) so the premium check can't be
-- bypassed by calling the API directly.
create policy "story_submissions_select_own" on public.story_submissions
  for select using (auth.uid() = user_id);

create policy "story_submissions_insert_own_premium" on public.story_submissions
  for insert with check (
    auth.uid() = user_id
    and exists (select 1 from public.profiles where id = auth.uid() and is_premium)
  );

-- Reading the Community Stories feed itself is free for everyone (same "free to
-- read, premium to create" split already used for comments vs. replies) --
-- only submitting requires premium.
create policy "story_submissions_select_public_approved" on public.story_submissions
  for select using (status = 'approved' and is_visible = true);

create policy "story_submissions_select_admin" on public.story_submissions
  for select using (public.is_admin());

create policy "story_submissions_update_admin" on public.story_submissions
  for update using (public.is_admin());
