-- Tracks when a user last changed their display name, so the app can enforce
-- a 6-month cooldown between changes. Null means "never changed via this
-- feature yet" -- existing users aren't retroactively locked out.
alter table public.profiles add column display_name_changed_at timestamptz;
