-- Admin-controlled curated sections: named, story-picked rows an admin can place at
-- fixed named insertion points ("anchors") on the consumer app's Home or Search page,
-- in any of the three display styles already built (poster carousel / backgrounded row
-- list / ranked numbered list), without needing a code change per row.
--
-- Anchors are named rather than a raw sort position an admin would have to reason
-- about -- they map 1:1 to real boundaries already in the mobile app's Home/Search
-- screens (see storyplugs-mobile's index.tsx / search.tsx):
--   home:   home_after_continue_reading, home_after_recommended,
--           home_before_browse_by_category, home_end
--   search: search_after_featured, search_after_suggestions,
--           search_after_new_this_week, search_end
-- No validity check ties anchor to target_page at the DB level (kept simple -- the
-- admin form only offers the anchors valid for whichever page is selected).

create table public.curated_sections (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  target_page text not null check (target_page in ('home', 'search')),
  anchor text not null,
  display_style text not null check (display_style in ('poster', 'row', 'ranked')),
  sort_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.curated_section_stories (
  id uuid primary key default gen_random_uuid(),
  section_id uuid not null references public.curated_sections(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  sort_order int not null default 0,
  unique (section_id, story_id)
);

create index curated_section_stories_section_idx on public.curated_section_stories (section_id);

create trigger set_curated_sections_updated_at
  before update on public.curated_sections
  for each row execute function public.set_updated_at();

alter table public.curated_sections enable row level security;
alter table public.curated_section_stories enable row level security;

create policy "curated_sections_select_active" on public.curated_sections
  for select using (is_active);

create policy "curated_sections_all_admin" on public.curated_sections
  for all using (public.is_admin()) with check (public.is_admin());

-- Join rows are only meaningful alongside a readable (active) parent section --
-- consumers select curated_section_stories via the same active-section join anyway.
create policy "curated_section_stories_select_active" on public.curated_section_stories
  for select using (
    exists (select 1 from public.curated_sections s where s.id = section_id and s.is_active)
  );

create policy "curated_section_stories_all_admin" on public.curated_section_stories
  for all using (public.is_admin()) with check (public.is_admin());
