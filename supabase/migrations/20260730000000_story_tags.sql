-- Story tags: admin-managed canonical vocabulary (mirrors categories' slug/name
-- table pattern) plus a many-to-many story_tags join, so stories can be
-- referenced by tag in addition to category. Tags feed the mood check-in
-- algorithm (buildMoodPicks) and are the foundation for future finer-grained
-- user preference matching beyond category alone.

create table public.tags (
  slug text primary key,
  name text not null,
  created_at timestamptz not null default now()
);

alter table public.tags enable row level security;

create policy "tags_select_all" on public.tags
  for select using (true);

create policy "tags_all_admin" on public.tags
  for all using (public.is_admin()) with check (public.is_admin());

create table public.story_tags (
  story_id uuid not null references public.stories(id) on delete cascade,
  tag_slug text not null references public.tags(slug) on delete cascade,
  primary key (story_id, tag_slug)
);

alter table public.story_tags enable row level security;

create policy "story_tags_select_all" on public.story_tags
  for select using (true);

create policy "story_tags_all_admin" on public.story_tags
  for all using (public.is_admin()) with check (public.is_admin());

create index story_tags_tag_slug_idx on public.story_tags (tag_slug);

-- Read-only view for the mobile app: aggregates each story's tag names into a
-- text[] so the existing select("*")-style fetches can pick up tags with a
-- table-name swap instead of every call site learning to join story_tags/tags.
-- security_invoker is required (Supabase/PG15+) so the querying user's own
-- RLS -- published-only for anon/authenticated, all rows for admins -- applies
-- via the underlying stories policies instead of the view owner's.
create view public.stories_with_tags
  with (security_invoker = true) as
  select
    s.*,
    coalesce(
      array_agg(t.name order by t.name) filter (where t.name is not null),
      '{}'
    ) as tags
  from public.stories s
  left join public.story_tags st on st.story_id = s.id
  left join public.tags t on t.slug = st.tag_slug
  group by s.id;
