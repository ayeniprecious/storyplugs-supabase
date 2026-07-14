-- Lets one notification carry a list of stories (e.g. "5 new stories this
-- week") instead of the single optional story_id notifications already had.
-- Kept alongside story_id rather than replacing it -- simple single-story
-- notifications still use that column, multi-story ones use this table.

create table public.notification_stories (
  notification_id uuid not null references public.notifications(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  sort_order integer not null default 0,
  primary key (notification_id, story_id)
);

create index notification_stories_notification_idx on public.notification_stories (notification_id, sort_order);

alter table public.notification_stories enable row level security;

-- Same access shape as notifications itself: a regular user can only see the
-- story list for a notification they actually received (have a recipient
-- row for); admins can see/write everything.
create policy "notification_stories_select_via_recipient" on public.notification_stories
  for select using (
    exists (
      select 1 from public.notification_recipients nr
      where nr.notification_id = notification_stories.notification_id and nr.user_id = auth.uid()
    )
  );

create policy "notification_stories_admin_all" on public.notification_stories
  for all using (public.is_admin()) with check (public.is_admin());
