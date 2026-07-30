-- Backfill for stories created before author_name/cover_color existed
-- (20260825000000), so they blend in with newly-authored/colored ones on
-- category rows instead of standing out with the neutral fallback color.
-- Picked from a curated palette rather than truly arbitrary hex values, so
-- every backfilled story still gets a color dark/saturated enough for white
-- title text to stay readable on top of it.
update public.stories
set cover_color = (array[
  '#C01918', '#1F4E79', '#2E7D32', '#6A1B9A', '#B45309',
  '#374151', '#7C2D12', '#134E4A', '#831843', '#3730A3'
])[1 + floor(random() * 10)::int]
where cover_color is null;

update public.stories
set author_name = 'StoryPlugs'
where author_name is null;
