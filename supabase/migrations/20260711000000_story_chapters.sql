-- Optional chapters for a story. Most stories have zero rows here and are read as a
-- single page (using stories.body directly); a story with rows here is presented on
-- the preview page as a clickable chapter list instead.

create table public.story_chapters (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories(id) on delete cascade,
  chapter_number integer not null,
  title text,
  body text not null,
  created_at timestamptz not null default now(),
  unique (story_id, chapter_number)
);

create index story_chapters_story_idx on public.story_chapters (story_id);

alter table public.story_chapters enable row level security;

-- public reads chapters only for stories that are themselves published
create policy "story_chapters_select_published" on public.story_chapters
  for select using (
    exists (
      select 1 from public.stories s
      where s.id = story_chapters.story_id and s.status = 'published'
    )
  );

create policy "story_chapters_all_admin" on public.story_chapters
  for all using (public.is_admin()) with check (public.is_admin());
