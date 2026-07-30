-- Short Stories becomes a first-class, admin-flagged story attribute
-- instead of just membership in a curated_sections row -- needed so
-- "Story of the Day" can deterministically pick from short stories only,
-- and so the admin can mark a story short (with its own image cover) right
-- at creation time.
alter table public.stories add column is_short_story boolean not null default false;

-- The 5 stories seeded in 20260823000000 for the old curated-section-driven
-- Short Stories row become the initial set of real short stories.
update public.stories
set is_short_story = true
where title in ('The Umbrella', 'Table for One', 'The Spare Key', 'New Shoes', 'The Long Way Home');

-- The Home "Short Stories" section is now a dedicated, always-on block fed
-- directly by is_short_story rather than admin-curated section membership.
-- Deactivate (not delete) the old curated_sections row so it stops
-- rendering without losing the row or its links.
update public.curated_sections
set is_active = false
where display_style = 'short';

-- Refresh stories_with_tags so is_short_story is included -- `select s.*`
-- is expanded and frozen at CREATE VIEW time, so the view needs to be
-- rebuilt after any column is added to stories (see 20260828000000's own
-- comment for the same lesson learned the first time).
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
