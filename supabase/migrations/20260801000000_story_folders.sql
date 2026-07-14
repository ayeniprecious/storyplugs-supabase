-- Story Folders: user-created collections in Library, just after Continue
-- Reading. A folder belongs to exactly one user; a story can sit in any
-- number of folders (many-to-many via story_folder_items). No admin
-- involvement -- this mirrors favorites'/story_views' plain
-- auth.uid() = user_id ownership pattern, not curated_sections' admin-owned one.

create table public.story_folders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index story_folders_user_idx on public.story_folders (user_id, created_at desc);

create trigger set_story_folders_updated_at
  before update on public.story_folders
  for each row execute function public.set_updated_at();

alter table public.story_folders enable row level security;

create policy "story_folders_select_own" on public.story_folders
  for select using (auth.uid() = user_id);

create policy "story_folders_insert_own" on public.story_folders
  for insert with check (auth.uid() = user_id);

create policy "story_folders_update_own" on public.story_folders
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "story_folders_delete_own" on public.story_folders
  for delete using (auth.uid() = user_id);

-- Join table: which stories sit in which folder, and when each was added --
-- added_at (not story published_at) drives the "last 3 added" cover peek on
-- each folder's tile, so re-adding a story later moves it back to the front.
create table public.story_folder_items (
  folder_id uuid not null references public.story_folders(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (folder_id, story_id)
);

create index story_folder_items_folder_idx on public.story_folder_items (folder_id, added_at desc);

alter table public.story_folder_items enable row level security;

-- Ownership is scoped through the parent folder (no user_id column on this
-- table itself) -- same indirection pattern curated_section_stories uses
-- through curated_sections, just checking the caller instead of is_admin().
create policy "story_folder_items_select_own" on public.story_folder_items
  for select using (
    exists (
      select 1 from public.story_folders f
      where f.id = story_folder_items.folder_id and f.user_id = auth.uid()
    )
  );

create policy "story_folder_items_insert_own" on public.story_folder_items
  for insert with check (
    exists (
      select 1 from public.story_folders f
      where f.id = story_folder_items.folder_id and f.user_id = auth.uid()
    )
  );

create policy "story_folder_items_delete_own" on public.story_folder_items
  for delete using (
    exists (
      select 1 from public.story_folders f
      where f.id = story_folder_items.folder_id and f.user_id = auth.uid()
    )
  );
