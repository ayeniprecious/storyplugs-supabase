-- Mature content flag, admin-editable via the same story_status_panel pattern as
-- is_featured/is_pinned (20260713000000_admin_features.sql) -- surfaced in the
-- consumer app as an "18+" badge on the new row-style story card.
alter table public.stories add column is_mature boolean not null default false;
