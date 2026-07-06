-- Turn three existing single-page stories into multi-chapter stories, one per a
-- different category, to exercise the chapters feature end-to-end. The stories.body
-- field becomes a short synopsis (used as the preview-page excerpt and in the share
-- message) instead of the full narrative, which now lives in story_chapters.

-- ========== THE LAST LETTER (forgiveness) ==========
update public.stories
set body = $$Nine years of silence between two brothers ends with a single unexplained letter. What happens next surprises them both.$$
where title = 'The Last Letter';

insert into public.story_chapters (story_id, chapter_number, title, body)
select id, 1, 'The Argument Nobody Remembers', $$Neither of them could say anymore exactly how it started — some comment at a family dinner nine years ago, taken the wrong way, answered with something worse.

What followed wasn't a single decision to stop speaking. It was smaller than that: a birthday missed on purpose, a call not returned, and then enough time passing that reaching out started to feel harder than staying silent.

Their mother stopped asking about it after the third Christmas. She'd learned that mentioning one brother to the other only ended the conversation early.$$
from public.stories where title = 'The Last Letter'
union all
select id, 2, 'The Letter', $$It arrived on a Tuesday, no return address, his own name in handwriting he hadn't seen in years.

Inside was a single page, shorter than he expected. No apology, no accounting of who owed what. Just: "I miss my brother. Call me when you can. — J"

He read it standing in the kitchen, then sitting at the table, then a third time before he let himself put it down. Nine years of reasons not to call suddenly felt very hard to name out loud.$$
from public.stories where title = 'The Last Letter'
union all
select id, 3, 'The Call', $$He picked up the phone twice and set it down before actually dialing. When his brother answered on the second ring, neither of them said anything for a moment.

"It's me," he finally said, as if there were any doubt.

They talked about their father's health first, safe ground. Then, without either of them deciding to, about nothing in particular — the way they used to. Twenty minutes in, it was almost easy.

Neither of them brought up the nine years. Some things, it turned out, didn't need the full story — just the first sentence.$$
from public.stories where title = 'The Last Letter';

-- ========== THE COMMUNITY GARDEN (hope) ==========
update public.stories
set body = $$A fenced-off, forgotten lot sits empty for six years until three neighbors decide to try something with it. It takes longer than they hoped.$$
where title = 'The Community Garden';

insert into public.story_chapters (story_id, chapter_number, title, body)
select id, 1, 'The Empty Lot', $$It had been fenced off since the building that used to stand there was torn down — six years of weeds, broken glass, and a padlocked gate nobody remembered the reason for.

Three neighbors who'd never spoken beyond a wave started talking about it at a stop sign one afternoon, half-joking about what they'd do with the space if the city ever let anyone in.

A month of phone calls and one skeptical city clerk later, they had a key.$$
from public.stories where title = 'The Community Garden'
union all
select id, 2, 'The First Season', $$Clearing it took longer than planting it. Broken concrete, a rusted shopping cart, roots from a tree that had been gone for a decade — all of it had to come out before anything could go in.

They planted late, argued about spacing, and lost half of what they put in the ground to a heat wave nobody had planned for.

By the end of that first season, there wasn't much to show for it except sore backs and a shared group chat that had somehow grown to include people whose names they hadn't known in spring.$$
from public.stories where title = 'The Community Garden'
union all
select id, 3, 'What Grew', $$The second spring, tomatoes came up in rows planted by people who, a year earlier, hadn't known each other's names. Nobody had expected it to work quite this well.

Now kids from the block stop by after school just to see what's ripe. The fence stays open during the day, propped with a brick nobody remembers placing there either.

None of it looked like much for a long time. That was mostly the point.$$
from public.stories where title = 'The Community Garden';

-- ========== THE CROSSING GUARD (everyday_heroes) ==========
update public.stories
set body = $$For twenty-two years, one woman stood at the same corner every morning. This is what she noticed, and why it mattered.$$
where title = 'The Crossing Guard';

insert into public.story_chapters (story_id, chapter_number, title, body)
select id, 1, 'The Corner', $$Rain or shine, she stood at the same corner every morning at 7:45, orange flag in hand, thirty minutes before the first bell.

The job paid little and asked for less — just be there, stop traffic, wave the kids across. Most people driving past never gave it a second thought.

She'd taken the job the year her own kids started school, meaning to do it for a season. Twenty-two years later, she was still the first face most of the neighborhood's children saw every morning.$$
from public.stories where title = 'The Crossing Guard'
union all
select id, 2, 'The Names', $$She learned every kid's name within the first few weeks of each school year, and most of their siblings' names too, going back a decade in some families.

She noticed things nobody asked her to notice — a kid who seemed too quiet three mornings running, a backpack that looked heavier than it should, a child who flinched at raised voices. Some mornings, a gentle "everything okay at home?" mattered more than anything taught in class that day.

Nobody trained her to watch for any of that. She just did.$$
from public.stories where title = 'The Crossing Guard'
union all
select id, 3, 'The Cards', $$When she finally retired, she expected a quiet last morning and not much else.

Instead, half the neighborhood showed up at her corner with handmade cards — some from kids who were grown now, a few with children of their own crossing that same street for the first time.

She still says most people don't notice a crossing guard at all. For twenty-two years, she noticed every single one of them back.$$
from public.stories where title = 'The Crossing Guard';
