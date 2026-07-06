-- Turn story_views from an append-only event log into one row per (user, story), so it can
-- represent "current reading state" for Continue Reading / Mark as Complete, not just analytics.

-- Keep only the most recent row per (user_id, story_id) before adding the uniqueness constraint.
delete from public.story_views a using public.story_views b
where a.user_id = b.user_id
  and a.story_id = b.story_id
  and a.created_at < b.created_at;

alter table public.story_views
  add column updated_at timestamptz not null default now(),
  add column progress_percent smallint not null default 0
    constraint story_views_progress_percent_range check (progress_percent >= 0 and progress_percent <= 100),
  add constraint story_views_user_story_unique unique (user_id, story_id);

create trigger set_story_views_updated_at before update on public.story_views
  for each row execute function public.set_updated_at();

-- Users could previously insert/select their own story_views rows but not update or delete them,
-- which blocks "mark as complete" and "remove from continue reading".
create policy "story_views_update_own" on public.story_views
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "story_views_delete_own" on public.story_views
  for delete using (auth.uid() = user_id);
