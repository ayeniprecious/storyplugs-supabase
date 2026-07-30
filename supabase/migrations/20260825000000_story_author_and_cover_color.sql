-- Two admin-editable fields: the writer's byline, and a solid cover color
-- used by the new "book cover" card style on category rows (in place of a
-- cover image) -- see storyplugs-mobile's category-row.tsx / book-cover-card.tsx.
-- Both nullable: existing stories have neither set yet, and the mobile card
-- falls back to a neutral color when cover_color is unset.
alter table public.stories add column author_name text;
alter table public.stories add column cover_color text;
