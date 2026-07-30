-- The first backfilled palette (20260826000000) read too pale/bright on
-- device. Re-roll every story's cover_color from a deeper, darker palette --
-- not just the ones still on the neutral fallback -- since none of these
-- were hand-picked by an admin yet.
update public.stories
set cover_color = (array[
  '#5C0F0F', '#12314A', '#123C24', '#3B0764', '#5C3510',
  '#1F2937', '#5A1A0A', '#0B3B3B', '#4A0E29', '#211258'
])[1 + floor(random() * 10)::int];
