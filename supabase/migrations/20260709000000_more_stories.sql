-- Seed 4 additional published stories per category (8 categories x 4 = 32 rows) so
-- every category has at least 5 stories total and category rows/grids feel full.

insert into public.stories (title, body, image_url, category, reflection_question, daily_lesson, source, status, published_at)
values
-- ========== KINDNESS ==========
(
  $$Exact Change$$,
  $$The line at the register had stalled — a young mother was short by a few dollars, her toddler squirming on her hip, her face flushing with the particular embarrassment of counting coins in public.

A man three people back stepped forward, set a bill on the counter, and said only, "I've been there," before stepping back into line like nothing had happened.

She tried to get his name. He just picked up his bag and told the cashier to have a good one.$$,
  $$https://picsum.photos/seed/sp-kindness-2/1200/800$$,
  'kindness',
  $$When has a stranger's small gesture saved you from an embarrassing moment?$$,
  $$A few dollars is nothing to give and everything to receive at the right moment.$$,
  'manual', 'published', now()
),
(
  $$The Parking Spot$$,
  $$The spot closest to the pharmacy door had just opened up, and two cars reached for it at the same time. The younger driver waved the older man ahead, then circled the lot twice more looking for another space.

He rolled down his window to thank her, apologizing for the inconvenience. She just laughed and said the walk would do her good anyway.

It cost her four extra minutes. He told the story to his daughter that night like it was the best part of his week.$$,
  $$https://picsum.photos/seed/sp-kindness-3/1200/800$$,
  'kindness',
  $$What's a small convenience you could give up today so someone else has an easier one?$$,
  $$Four minutes is a small price for someone else's relief.$$,
  'manual', 'published', now()
),
(
  $$Two Coffees$$,
  $$A regular at the corner café started paying for two coffees each morning — one for herself, one for whoever ordered next. She never left a name, just told the barista to pass it on.

Within a month, a chalkboard by the register was covered in tally marks nobody had asked for. Strangers kept the chain going long after she moved out of state.

The barista still doesn't know her name. She knows exactly what she started, though, every time the board fills up again.$$,
  $$https://picsum.photos/seed/sp-kindness-4/1200/800$$,
  'kindness',
  $$Could you start something today that keeps going even after you're not there to see it?$$,
  $$Some kindness is designed to outlive the person who started it.$$,
  'manual', 'published', now()
),
(
  $$The Note in the Library Book$$,
  $$Tucked inside a secondhand copy of an old paperback, she found a folded note in careful handwriting: "Whoever is reading this, I hope today treats you gently." No name, no date.

She almost threw it away, then didn't. Instead she wrote her own note, tucked it into a different book, and returned both to the library shelf without telling anyone.

Neither of them ever found out who started it, or how many books it had traveled through by then.$$,
  $$https://picsum.photos/seed/sp-kindness-5/1200/800$$,
  'kindness',
  $$What's something small you could leave behind for a stranger to find?$$,
  $$You rarely get to see where a small kindness ends up traveling.$$,
  'manual', 'published', now()
),

-- ========== FAMILY ==========
(
  $$The Recipe Card$$,
  $$The card was stained and soft at the corners, her grandmother's handwriting fading in some of the measurements. She'd watched her make the dish a hundred times but never written it down herself.

The first attempt was close but not quite right — missing the small pinch of something her grandmother had never bothered naming. It took three more tries and a phone call to get it exact.

Now her own daughter stands on a stool beside her, watching the same steps, asking the same question about the pinch of something nobody writes down.$$,
  $$https://picsum.photos/seed/sp-family-2/1200/800$$,
  'family',
  $$What's a family tradition you've been meaning to actually learn, not just watch?$$,
  $$Some things only get passed down if someone asks before it's too late.$$,
  'manual', 'published', now()
),
(
  $$Driveway Basketball$$,
  $$He came home exhausted most nights, but the hoop over the garage meant fifteen minutes of one-on-one before dinner, win or lose, rain or not.

Some nights it was the last thing he wanted to do. He did it anyway, mostly badly, missing more shots than he made.

Twenty years later his son, home for the holidays, mentioned it was his favorite part of childhood — not a vacation, not a gift, just the sound of a ball on the driveway after work.$$,
  $$https://picsum.photos/seed/sp-family-3/1200/800$$,
  'family',
  $$What's a small, unremarkable habit that might mean more to someone than you realize?$$,
  $$The plain, repeated things are usually what people remember, not the big occasions.$$,
  'manual', 'published', now()
),
(
  $$The Photo Wall$$,
  $$Four siblings, four different cities, and a group chat that mostly went quiet for weeks at a time. Someone started a shared photo album instead — no messages required, just pictures.

A kid's school play. A bad haircut. A sunset from someone's new apartment. Nothing important, posted without comment, seen without needing a reply.

It became the thing that actually held them together, more than any of the calls they kept meaning to schedule and never did.$$,
  $$https://picsum.photos/seed/sp-family-4/1200/800$$,
  'family',
  $$Is there an easier way to stay close to people than the way you're currently trying?$$,
  $$Connection doesn't always need conversation — sometimes it just needs showing up.$$,
  'manual', 'published', now()
),
(
  $$Waiting Up$$,
  $$No matter how late she came home as a teenager, the kitchen light was always on, her mother pretending to read at the table, never actually asleep until the door clicked shut.

At the time it felt like being checked up on. She rolled her eyes at it more than once.

Now, with a teenager of her own out past curfew, she finds herself at that same table with a book she isn't reading, understanding for the first time exactly what that light was for.$$,
  $$https://picsum.photos/seed/sp-family-5/1200/800$$,
  'family',
  $$Is there something a parent did for you that you only understood once you were older?$$,
  $$Some love looks like worry until you're the one waiting up.$$,
  'manual', 'published', now()
),

-- ========== FAITH ==========
(
  $$The Empty Seat$$,
  $$Every week for three years, she saved the seat beside her at the end of the pew, even when no one came to fill it. A few people asked why she bothered.

Then one Sunday a man slipped in late, unsure where to sit, and she simply patted the space beside her without a word.

He came back the next week, and the one after. She never did explain why she'd kept saving that seat — she just says some things are worth being ready for.$$,
  $$https://picsum.photos/seed/sp-faith-2/1200/800$$,
  'faith',
  $$Is there room you're keeping open for someone who hasn't arrived yet?$$,
  $$Sometimes faith looks like patience for a seat nobody else notices is empty.$$,
  'manual', 'published', now()
),
(
  $$Sunrise Service$$,
  $$Attendance had shrunk to a handful over the years, but the small group still met on the hill before dawn every Easter, blankets and thermoses in hand.

A jogger passing by one morning slowed, then stopped altogether, drawn in by nothing more than the sound of quiet singing against the coming light.

She stayed until the service ended, said nothing, and came back the following year on her own, thermos in hand like she'd always belonged there.$$,
  $$https://picsum.photos/seed/sp-faith-3/1200/800$$,
  'faith',
  $$What's something you keep doing quietly, even without a big audience?$$,
  $$Small, faithful things are sometimes exactly what a stranger needed to witness.$$,
  'manual', 'published', now()
),
(
  $$The Borrowed Hymnal$$,
  $$She'd come alone, unsure of the words, standing awkwardly through the first hymn with empty hands. The woman beside her simply tilted her own hymnal so they could share it, without a glance or a word.

By the second verse they were half-singing together, strangers finding the same line on the same page.

After the service they introduced themselves for the first time, as if the hymnal had already done the proper introduction.$$,
  $$https://picsum.photos/seed/sp-faith-4/1200/800$$,
  'faith',
  $$When has a small, wordless gesture made you feel instantly less alone?$$,
  $$Belonging sometimes starts with someone simply making room on the page.$$,
  'manual', 'published', now()
),
(
  $$The Prayer List$$,
  $$They'd only spoken a handful of times, mostly small talk after a long flight delay years earlier. She never expected to hear from him again.

When she was going through a hard season, a card arrived out of nowhere: he'd kept her name on his church's prayer list the whole time, ever since that one conversation.

She still doesn't fully understand how a stranger held onto her that long, but she's kept his name on her own list ever since.$$,
  $$https://picsum.photos/seed/sp-faith-5/1200/800$$,
  'faith',
  $$Who might still be quietly holding you in mind, long after your last conversation?$$,
  $$You rarely find out who's been carrying you until they tell you.$$,
  'manual', 'published', now()
),

-- ========== FORGIVENESS ==========
(
  $$The Phone Call$$,
  $$Ten years of silence had started over something neither of them could fully explain anymore, just years of neither one wanting to be the one to call first.

When their father got sick, she finally dialed the old number, unsure if it even still worked. He picked up on the second ring, like no time had passed.

Neither mentioned the ten years. They just started talking about their father, and kept talking long after the news about him had run out.$$,
  $$https://picsum.photos/seed/sp-forgiveness-2/1200/800$$,
  'forgiveness',
  $$Is there a call you've been putting off for reasons that don't feel as strong as they used to?$$,
  $$Some silences only end when someone decides the reason for them no longer matters.$$,
  'manual', 'published', now()
),
(
  $$The Empty Chair$$,
  $$He hadn't been part of her life growing up, and she'd promised herself years ago that his absence wouldn't earn him a seat at her wedding.

But when the day came, she found herself asking the venue for one more chair at the family table anyway, without telling anyone why.

He never did show up. She says leaving the chair wasn't really for him — it was the moment she realized she'd already forgiven him, whether or not he ever knew it.$$,
  $$https://picsum.photos/seed/sp-forgiveness-3/1200/800$$,
  'forgiveness',
  $$Can forgiveness happen even if the other person never finds out about it?$$,
  $$Sometimes forgiving someone is a decision you make entirely on your own.$$,
  'manual', 'published', now()
),
(
  $$Returning the Tools$$,
  $$The fence dispute had gone on so long neither neighbor could remember which of them stopped speaking first, just years of silently avoiding eye contact over the hedge.

When his mower broke, he was too proud to ask for help, until his son borrowed one anyway, whether he liked it or not.

Returning it, he found himself staying to help fix the very fence they'd once argued about, and neither of them ever mentioned bringing it up again.$$,
  $$https://picsum.photos/seed/sp-forgiveness-4/1200/800$$,
  'forgiveness',
  $$What's a small, practical excuse you could use to end a standoff that's lasted too long?$$,
  $$Sometimes reconciliation doesn't need an apology — it just needs an opening.$$,
  'manual', 'published', now()
),
(
  $$The Apology Text$$,
  $$The falling out had been so long ago neither of them could agree anymore on who'd said what. Years of birthdays and holidays passed with nothing but silence between old friends.

One evening, half on impulse, she typed a single line — "I'm sorry, I miss you" — and sent it before she could talk herself out of it.

The reply came within a minute: "I miss you too. Coffee this week?" Twelve years of silence, undone by eleven words.$$,
  $$https://picsum.photos/seed/sp-forgiveness-5/1200/800$$,
  'forgiveness',
  $$What's the shortest message that could end a silence you've been carrying?$$,
  $$Reconciliation is often much closer than the years of silence make it feel.$$,
  'manual', 'published', now()
),

-- ========== HOPE ==========
(
  $$The Seed Bank$$,
  $$The wildfire took most of the valley's orchards in a single afternoon, along with decades of careful cultivation nobody thought to insure against fire.

An old farmer, though, had spent thirty years quietly saving seeds from every harvest, jars of them labeled and stored in his cellar for no reason he could fully explain.

The next spring, saplings grown from those jars went back into the ground across a dozen properties, seeded from the one thing the fire never reached.$$,
  $$https://picsum.photos/seed/sp-hope-2/1200/800$$,
  'hope',
  $$What are you quietly saving or preparing now that might matter later, even if you're not sure why?$$,
  $$Preparation nobody asks for can turn out to be exactly what's needed.$$,
  'manual', 'published', now()
),
(
  $$The Night Shift$$,
  $$The hardest shifts were always the overnight ones, when the ward was quiet except for machines and the occasional call light. She kept a small box in her locker of notes from patients and families, read on the worst nights.

One note, from a man whose wife hadn't made it, thanked her simply for being kind at 3am when kindness felt impossible to give.

She still keeps that note on top. It's not the saves that get her through some nights — it's being told the trying mattered too.$$,
  $$https://picsum.photos/seed/sp-hope-3/1200/800$$,
  'hope',
  $$What keeps you going on the days when the outcome isn't the one you hoped for?$$,
  $$Sometimes the effort matters as much to someone else as the result does.$$,
  'manual', 'published', now()
),
(
  $$Waiting for Spring$$,
  $$The harvest had failed two years running, and the bank had stopped returning his calls with anything but bad news. Replanting again made no financial sense on paper.

His late mentor's voice kept coming back to him though — "the crop that fails still teaches the ground something" — words he hadn't understood at the time and barely understood now.

He planted anyway, smaller and more carefully than before. That third spring, for the first time in years, everything came up green.$$,
  $$https://picsum.photos/seed/sp-hope-4/1200/800$$,
  'hope',
  $$Is there something you've failed at twice that might still be worth one more try?$$,
  $$Hope sometimes just means planting again after two seasons of nothing.$$,
  'manual', 'published', now()
),
(
  $$The Job After Fifty$$,
  $$Six months of rejections had worn down more than his savings — it had worn down the part of him that believed anyone still wanted what he had to offer at fifty-four.

A small company finally called back, not for the role he'd applied for, but for one they hadn't yet posted, one that fit him better than anything he'd tried for.

He tells younger colleagues now that the six months of no felt endless, right up until the one yes that made all of it worth it.$$,
  $$https://picsum.photos/seed/sp-hope-5/1200/800$$,
  'hope',
  $$What's kept you going through a long stretch of no's?$$,
  $$The right yes sometimes needs all the wrong no's to happen first.$$,
  'manual', 'published', now()
),

-- ========== COMMUNITY ==========
(
  $$The Tool Library$$,
  $$Nobody on the block needed a ladder more than twice a year, or a table saw more than once, yet every garage had one anyway, gathering dust.

Someone suggested a shared shed instead — one ladder, one saw, a sign-out sheet taped to the door, and an honor system nobody ever seemed to break.

Three years in, the shed holds more tools than any single garage ever could, and neighbors who once only waved now spend Saturday mornings fixing things together.$$,
  $$https://picsum.photos/seed/sp-community-2/1200/800$$,
  'community',
  $$What's something you own that could be shared instead of duplicated eight times on your street?$$,
  $$Shared resources often build more than they save.$$,
  'manual', 'published', now()
),
(
  $$The Potluck Fence$$,
  $$It started with two neighbors talking over a fence while grilling on the same evening, and deciding it made more sense to just combine dinners.

A few weeks later it was four families. By the end of summer, the fence had become a standing weekly potluck, folding tables set up in whoever's yard had the most shade that day.

Winter didn't end it — it just moved the tables indoors, rotating houses, still going years after that first accidental dinner.$$,
  $$https://picsum.photos/seed/sp-community-3/1200/800$$,
  'community',
  $$What ordinary interaction in your life could turn into something bigger if you just said yes to it once?$$,
  $$Community sometimes starts by accident and stays on purpose.$$,
  'manual', 'published', now()
),
(
  $$Snow Day Shovels$$,
  $$After watching an elderly neighbor struggle with her driveway for the third winter in a row, a group of kids on the block decided to start a shoveling route, no charge, no schedule, just whenever it snowed.

It grew from one driveway to eleven over two winters, kids trading houses depending on who could get there fastest after the snow stopped.

The neighbor tries to pay them every time. They always say no, and take hot chocolate instead.$$,
  $$https://picsum.photos/seed/sp-community-4/1200/800$$,
  'community',
  $$What's a need you've noticed nearby that a small, unpaid effort could actually solve?$$,
  $$The most lasting community work is often started by the people too young to overthink it.$$,
  'manual', 'published', now()
),
(
  $$The Repair Café$$,
  $$The toaster wasn't worth fixing, technically — a new one cost less than the part. She brought it to the monthly repair café anyway, more out of curiosity than expectation.

A retired electrician spent twenty minutes on it for free, chatting the whole time about the years he'd spent doing this professionally before nobody wanted repairs anymore.

She left with a working toaster and his phone number, in case anything else broke. Something usually does.$$,
  $$https://picsum.photos/seed/sp-community-5/1200/800$$,
  'community',
  $$What's something you've thrown away recently that someone nearby could have fixed instead?$$,
  $$Fixing things together tends to fix more than the object itself.$$,
  'manual', 'published', now()
),

-- ========== CHILDREN ==========
(
  $$The Reading Buddy$$,
  $$He was two years older and not much of a reader himself, paired almost as an afterthought with a younger student who dreaded reading time more than anything else in the day.

Neither of them expected much from it. But sounding out words together, neither one embarrassed in front of the other, something clicked that hadn't clicked with any adult tutor.

By spring, the younger boy was reading above grade level, and the older one had discovered, somewhat to his own surprise, that he liked books after all.$$,
  $$https://picsum.photos/seed/sp-children-2/1200/800$$,
  'children',
  $$Who might you be underestimating as a teacher, including yourself?$$,
  $$Sometimes peers teach each other things adults can't.$$,
  'manual', 'published', now()
),
(
  $$The Empty Cubby$$,
  $$She noticed it in October — one student's lunch cubby was empty more often than not, and the kid never mentioned it, never asked, just quietly went without.

Without making it a thing, she started packing an extra lunch each morning, leaving it in the cubby before anyone arrived, no note, no explanation.

It continued all year. She never told the family, and the student never asked who it was from — some things work better left unsaid.$$,
  $$https://picsum.photos/seed/sp-children-3/1200/800$$,
  'children',
  $$What's a quiet need nearby you could meet without needing anyone to notice you did?$$,
  $$Not every kindness needs credit to matter.$$,
  'manual', 'published', now()
),
(
  $$The Recess Circle$$,
  $$She noticed the same few kids standing alone by the fence every recess, never quite invited into any of the games already running.

So she started asking them by name to join hers, no big announcement, just "we need one more for this team," every single day until it became habit.

By the end of the year, the fence was empty at recess, and nobody but her teacher ever noticed why.$$,
  $$https://picsum.photos/seed/sp-children-4/1200/800$$,
  'children',
  $$Who's standing by the fence in your life, waiting for someone to ask them in?$$,
  $$Inclusion is rarely dramatic — it's usually just one small invitation, repeated.$$,
  'manual', 'published', now()
),
(
  $$The Homework Table$$,
  $$Her kitchen table was quiet most weekday afternoons, and she knew from the school pickup line that not every kid on the block had somewhere calm to do homework.

She started leaving the door open after school, snacks out, no questions asked about why they were there instead of home.

Some afternoons it was one kid, some afternoons five. None of them ever needed an invitation twice — they just knew the table would be there.$$,
  $$https://picsum.photos/seed/sp-children-5/1200/800$$,
  'children',
  $$What space do you have that's sitting empty when someone nearby could use it?$$,
  $$An open door sometimes matters more than anything said through it.$$,
  'manual', 'published', now()
),

-- ========== EVERYDAY HEROES ==========
(
  $$The Night Dispatcher$$,
  $$The call came in at 2am, a panicked voice barely getting words out. She'd taken thousands of calls over eleven years and still slowed her own voice down deliberately, the way she'd learned mattered most in the first ten seconds.

She talked the caller through it for six minutes before help arrived, calm the entire time, though nobody on the other end ever saw her face or learned her name.

She went home at dawn, as always, and was back at her desk the next night.$$,
  $$https://picsum.photos/seed/sp-heroes-2/1200/800$$,
  'everyday_heroes',
  $$Whose calm, unseen work has steadied you during a moment of panic?$$,
  $$Some of the most important work happens where no one can see it.$$,
  'manual', 'published', now()
),
(
  $$The Sanitation Route$$,
  $$Twenty years on the same route meant he knew which houses had new babies, which ones had lost someone, and which elderly residents hadn't put their bins out in a way that worried him.

On those mornings, he'd knock, just to check. More than once, that knock caught a problem early enough to matter.

He says most people don't notice a garbage truck at all. He noticed every house on that street, every single week, for two decades.$$,
  $$https://picsum.photos/seed/sp-heroes-3/1200/800$$,
  'everyday_heroes',
  $$What's an overlooked job in your neighborhood that quietly keeps people safe?$$,
  $$Noticing people is its own kind of service, no matter the job title attached to it.$$,
  'manual', 'published', now()
),
(
  $$The Substitute$$,
  $$Nobody wanted that classroom — the one with the reputation, the one regular teachers requested to avoid. She took it anyway, week after week, when the district called.

She learned every name by the second day, expected nothing less than respect, and gave more patience than most of those kids had ever been shown by an adult.

Years later, one of them tracked her down just to say she was the only teacher that year who hadn't given up on the class before it started.$$,
  $$https://picsum.photos/seed/sp-heroes-4/1200/800$$,
  'everyday_heroes',
  $$Who took on something difficult that nobody else wanted, on your behalf?$$,
  $$Showing up for the hard rooms is its own quiet form of heroism.$$,
  'manual', 'published', now()
),
(
  $$The Late Shift Pharmacist$$,
  $$The medication wasn't in stock, and the nearest pharmacy with it was forty minutes away, closing in twenty. It was for a child with a fever climbing fast.

He called every store within driving distance himself, found one that had it, and told the parents to go, promising to explain the delay to his own manager later.

It cost him nothing but a phone call and a bit of trouble. To the family driving through the night, it was the whole difference.$$,
  $$https://picsum.photos/seed/sp-heroes-5/1200/800$$,
  'everyday_heroes',
  $$What's a phone call or extra step you could make today that costs you little but means everything to someone else?$$,
  $$Small extra effort, at the right moment, can matter more than any grand gesture.$$,
  'manual', 'published', now()
);
