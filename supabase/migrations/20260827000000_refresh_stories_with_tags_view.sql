-- stories_with_tags was created (20260730000000) using `select s.*, ...`,
-- but Postgres expands `*` into a fixed column list at CREATE VIEW time and
-- does not re-expand it just because the underlying table gained columns
-- later -- the view kept silently omitting author_name/cover_color
-- (20260825000000) even though `s.*` reads as if it should include
-- everything. `create or replace view` forces Postgres to re-expand `s.*`
-- against the table's current column list. Body is otherwise identical to
-- the original.
create or replace view public.stories_with_tags
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
