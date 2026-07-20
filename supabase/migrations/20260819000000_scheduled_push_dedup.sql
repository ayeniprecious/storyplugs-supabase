-- Supports the new scheduled-push-sender edge function: tracks the last calendar
-- day each user was sent an automated (non-admin) notification, so a user never
-- gets two automated sends on the same day even if a cron run overlaps or retries.
alter table public.profiles add column last_notified_date date;
