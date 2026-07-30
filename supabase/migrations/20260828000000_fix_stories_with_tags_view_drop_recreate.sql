-- The previous attempt (20260827000000) used `create or replace view`, but
-- Postgres only allows that to ADD columns at the very end of a view's
-- existing output list -- it can't insert columns before one that's already
-- there. `tags` was the last column in the original view, so inserting
-- author_name/cover_color via `s.*` pushed `tags` out of its frozen
-- position, which Postgres reads as an attempt to rename it (hence the
-- 42P16 error). Drop and recreate instead -- body is otherwise identical.
drop view public.stories_with_tags;

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
