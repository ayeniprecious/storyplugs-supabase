-- Without this, changes admins make in the dashboard never reach an already-running
-- app: the mobile client subscribes to postgres_changes on app_settings, but Supabase
-- only emits those events for tables added to the supabase_realtime publication.
alter publication supabase_realtime add table public.app_settings;
