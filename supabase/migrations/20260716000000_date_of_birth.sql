-- Date of birth, captured on the new multi-step sign-up flow alongside gender
-- (profiles.gender already exists from 20260713000000_admin_features.sql).
alter table public.profiles
  add column if not exists date_of_birth date;
