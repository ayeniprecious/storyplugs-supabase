-- Add an "Anytime" delivery-time option (encoded as null, meaning "no specific
-- time preference") and make it the default for new profiles. Nothing currently
-- reads notification_time for actual send scheduling (send-notification is an
-- admin-triggered broadcast, not a per-user cron job), so this is UI-only and
-- safe -- existing users keep whatever specific time they already chose.
alter table public.profiles alter column notification_time drop not null;
alter table public.profiles alter column notification_time set default null;
