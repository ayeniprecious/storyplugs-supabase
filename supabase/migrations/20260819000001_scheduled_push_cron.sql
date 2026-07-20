-- Wires the scheduled-push-sender edge function to pg_cron, one job per delivery
-- slot. Requires the pg_cron and pg_net extensions (enabled below) and the
-- scheduled-push-sender function already deployed with "Verify JWT" turned off and
-- a CRON_SECRET function secret set to the same value used here.
--
-- IMPORTANT: replace both placeholders before running --
--   <CRON_SECRET>   -- the exact value you set as the function's CRON_SECRET secret
--   <PROJECT_REF>   -- your Supabase project ref (from the project URL)
--
-- Note: cron times below run in UTC (pg_cron's default), and there's no per-user
-- timezone handling anywhere in this schema yet -- "6:00 AM" in the app's own time
-- slot picker means 6:00 AM UTC here, not each user's local time. Worth knowing if
-- most users are in one timezone and the slots feel off.

create extension if not exists pg_cron;
create extension if not exists pg_net;

select cron.schedule(
  'scheduled-push-06',
  '0 6 * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/scheduled-push-sender',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', '<CRON_SECRET>'),
    body := jsonb_build_object('slot', '06:00')
  );
  $$
);

select cron.schedule(
  'scheduled-push-08',
  '0 8 * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/scheduled-push-sender',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', '<CRON_SECRET>'),
    body := jsonb_build_object('slot', '08:00')
  );
  $$
);

select cron.schedule(
  'scheduled-push-12',
  '0 12 * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/scheduled-push-sender',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', '<CRON_SECRET>'),
    body := jsonb_build_object('slot', '12:00')
  );
  $$
);

select cron.schedule(
  'scheduled-push-18',
  '0 18 * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/scheduled-push-sender',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', '<CRON_SECRET>'),
    body := jsonb_build_object('slot', '18:00')
  );
  $$
);

select cron.schedule(
  'scheduled-push-21',
  '0 21 * * *',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/scheduled-push-sender',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Cron-Secret', '<CRON_SECRET>'),
    body := jsonb_build_object('slot', '21:00')
  );
  $$
);
