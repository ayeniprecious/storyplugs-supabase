-- Personalization preferences captured during onboarding right after sign-up,
-- so the app can tailor story recommendations to each user.
-- interests: category slugs the user picked (matches categories.slug)
-- personal_goals: what they hope to get out of the app (see the app's GOAL_OPTIONS)
-- story_length_pref: preferred story length

alter table public.profiles
  add column if not exists interests text[] not null default '{}',
  add column if not exists personal_goals text[] not null default '{}',
  add column if not exists story_length_pref text
    check (story_length_pref in ('short', 'medium', 'long', 'any'));
