-- 1. Welcome notification was firing at signUp() time (auth.users insert),
-- before email confirmation -- move it to a client-invoked RPC fired once,
-- the first time the user actually reaches Home.
alter table public.profiles add column if not exists welcome_notified_at timestamptz;

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name');

  return new;
end;
$$ language plpgsql security definer set search_path = public;

create or replace function public.send_welcome_notification()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_app_name text;
  v_already_sent boolean;
begin
  if auth.uid() is null then
    return;
  end if;

  select welcome_notified_at is not null into v_already_sent
  from public.profiles where id = auth.uid();

  if v_already_sent then
    return;
  end if;

  -- Set the flag before sending so a second call racing in (e.g. a fast
  -- remount) can't double-send while the first call is still in flight.
  update public.profiles set welcome_notified_at = now() where id = auth.uid();

  select (value #>> '{}') into v_app_name from public.app_settings where key = 'app_name';

  perform public.notify_user(
    auth.uid(),
    'Welcome to ' || coalesce(v_app_name, 'StoryPlugs') || '!',
    'A story every day, made for you. We''re glad you''re here.'
  );
end;
$$;

grant execute on function public.send_welcome_notification() to authenticated;

-- 2. Continue Reading notification was firing twice: the trigger re-checks
-- "does this user have exactly 5 not-completed stories" on every insert AND
-- every update to story_views, but a plain progress-percent update on a row
-- that was already counted doesn't change the count -- it just re-fires the
-- same true condition a second time. Only an insert of a new row, or a
-- completed story being reopened, can actually make the count cross into 5.
create or replace function public.notify_continue_reading_five()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
  v_story_ids uuid[];
  v_crossed_into_five boolean;
begin
  if new.completed or new.user_id is null then
    return new;
  end if;

  v_crossed_into_five := (
    TG_OP = 'INSERT'
    or (TG_OP = 'UPDATE' and OLD.completed = true and NEW.completed = false)
  );

  if not v_crossed_into_five then
    return new;
  end if;

  select count(*) into v_count
  from public.story_views
  where user_id = new.user_id and completed = false;

  if v_count = 5 then
    select array_agg(story_id) into v_story_ids
    from (
      select story_id from public.story_views
      where user_id = new.user_id and completed = false
      order by created_at desc
      limit 5
    ) recent;

    perform public.notify_user(
      new.user_id,
      '5 stories waiting for you',
      'Your Continue Reading list just hit 5 -- pick one up where you left off.',
      v_story_ids
    );
  end if;

  return new;
end;
$$;

-- 3. "Short Stories" Home section -- a new curated_sections display style,
-- plus a handful of short kindness stories to seed it with so the section
-- actually shows something without a separate admin step.
alter table public.curated_sections drop constraint if exists curated_sections_display_style_check;
alter table public.curated_sections add constraint curated_sections_display_style_check
  check (display_style in ('poster', 'row', 'ranked', 'short'));

insert into public.stories (title, body, category, status, published_at, daily_lesson) values
(
  'The Umbrella',
  'Rain hammered the bus stop, and Maya had exactly one umbrella and one shrinking hope of staying dry. Beside her, an old man in a thin coat hunched against the wind, no umbrella of his own, just a folded newspaper held uselessly over his head.

She almost didn''t say anything. It would have been easy not to. But she stepped sideways, tilted the umbrella until it covered them both, and said, "There''s room."

He looked at her like she''d handed him something rare. "You sure?"

"I''m sure."

They stood there together, shoulders nearly touching, water drumming above them, saying nothing else. When her bus came, she offered him the umbrella outright. He refused twice, then accepted it the third time, the way people do when they''ve run out of polite reasons to say no.

She never saw him again. She never needed to. Some kindnesses aren''t about being remembered — they''re just about someone, somewhere, staying a little drier than they would have otherwise.',
  'kindness',
  'published',
  now(),
  'You don''t need a grand gesture to make someone''s day easier — sometimes it''s just room under an umbrella.'
),
(
  'Table for One',
  'The waiter had already decided how this would go: a party of one, ordering slow, tipping small, taking up a table someone else could''ve used. He''d seen it before.

But the old woman at table nine wasn''t sad. She ordered the soup, then asked him to sit for a moment, just a moment, and tell her one good thing that happened to him today.

He almost brushed her off. He had six other tables. But something in the way she asked — like the answer actually mattered to her — made him pause.

"My daughter took her first steps this morning," he said, surprised to hear himself say it out loud.

Her whole face opened up. "That," she said, "is the only thing that matters today."

He came back to check on her twice more than he needed to. When she left, she''d written on the receipt: *Thank you for the good thing.* He kept it in his apron pocket for the rest of the week.',
  'kindness',
  'published',
  now(),
  'Asking someone about their day — and actually listening to the answer — is its own small gift.'
),
(
  'The Spare Key',
  'Daniel found the wallet on the sidewalk, thick with cash and a driver''s license photo of a tired-looking man. Three hundred dollars, easy. Nobody would know.

He thought about it for exactly as long as it took to walk to the corner and back. Then he looked up the address on the license and walked the eleven blocks himself instead of taking the bus fare he didn''t have.

The man who opened the door looked at the wallet like it was a ghost. "I dropped this four hours ago. I''d already given up." His hands were shaking. "There''s rent money in there. I didn''t know what I was going to tell my landlord."

He tried to give Daniel half of it. Daniel said no, then said it again more firmly when the man insisted a second time.

"Just doing what anyone would do," Daniel said, though he knew that wasn''t quite true — he knew exactly how easy it would have been to just keep walking.',
  'kindness',
  'published',
  now(),
  'Honesty is easiest to talk about and hardest to practice exactly when no one is watching.'
),
(
  'New Shoes',
  'Mrs. Alvarez noticed the boy at the bus stop every morning, same spot, same threadbare sneakers with a sole peeling away from the toe like a tired smile. He never complained. He just walked carefully, like the shoes were a secret he was managing.

She wasn''t rich. She counted her grocery money twice most weeks. But she remembered exactly what it felt like to be a kid whose shoes gave away how little his family had.

She bought a plain pair, his size, guessed from watching him for three weeks straight, and left them at the bus stop with a note: *Found these — thought they might fit someone.* No name. No fuss. Just shoes, and a small lie kind enough to let him take them without owing anyone anything.

The next morning, he was wearing them. He looked around, like he was trying to figure out who to thank. She sipped her coffee on her porch across the street and said nothing, and felt, for reasons she couldn''t fully explain, like the richest woman on the block.',
  'kindness',
  'published',
  now(),
  'A kindness given without needing credit is still a kindness — often the truest kind.'
),
(
  'The Long Way Home',
  'It was supposed to be a ten-minute walk. Instead, Priya spent forty-five minutes going the long way, matching her pace to a stranger''s wheelchair over three blocks of broken, tilted sidewalk that the smooth route simply didn''t have.

She hadn''t planned to. She''d just been walking behind him, watching him navigate around cracked pavement and curbs with no ramps, and something in her didn''t want to just walk past and let him figure it out alone.

"You really don''t have to do this," he said, for the third time.

"I know," she said. "I want to."

They talked about nothing in particular — his dog, her exams, a coffee shop he liked two streets over. When they reached his building, he thanked her, and she realized she''d meant it too: it hadn''t felt like a detour. It had felt like the actual point of the walk.',
  'kindness',
  'published',
  now(),
  'Slowing down to match someone else''s pace is its own quiet form of respect.'
)
on conflict do nothing;

do $$
declare
  v_section_id uuid;
begin
  insert into public.curated_sections (title, target_page, anchor, display_style, sort_order, is_active)
  values ('Short Stories', 'home', 'home_after_reflection', 'short', 0, true)
  returning id into v_section_id;

  insert into public.curated_section_stories (section_id, story_id, sort_order)
  select v_section_id, id, row_number() over (order by published_at desc) - 1
  from public.stories
  where title in ('The Umbrella', 'Table for One', 'The Spare Key', 'New Shoes', 'The Long Way Home');
end $$;
