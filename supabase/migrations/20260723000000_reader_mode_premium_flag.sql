-- Gates Reader Mode (auto-scroll, reader-specific theme, font controls) behind a simple
-- premium flag. No real billing yet -- admins toggle this manually in the dashboard until
-- store billing (RevenueCat/StoreKit/Play Billing) is wired up.
alter table public.profiles add column is_premium boolean not null default false;

-- profiles_update_own has no column-level restriction, so without this a user could grant
-- themselves premium with a direct client-side update. Silently reverts any change to
-- is_premium unless the request comes from an admin.
create or replace function public.protect_is_premium()
returns trigger as $$
begin
  if not public.is_admin() and new.is_premium is distinct from old.is_premium then
    new.is_premium := old.is_premium;
  end if;
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger protect_profiles_is_premium
  before update on public.profiles
  for each row execute function public.protect_is_premium();
