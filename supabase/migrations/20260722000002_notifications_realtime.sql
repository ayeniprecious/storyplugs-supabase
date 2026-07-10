-- Lets the mobile app hear about new notifications and edits to existing ones live,
-- instead of only picking them up on next app relaunch. Wrapped so this is safe to run
-- even if either table was already added to the publication previously.
do $$
begin
  alter publication supabase_realtime add table public.notification_recipients;
exception when duplicate_object then
  null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.notifications;
exception when duplicate_object then
  null;
end $$;
