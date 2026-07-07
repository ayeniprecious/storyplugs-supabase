-- The three chaptered stories' chapters were too short to scroll (barely filled one
-- screen), so the reading-progress bar never moved. Expand each chapter to real
-- short-story length (roughly 600-700 words / several screens on mobile) with more
-- scene-setting, dialogue, and detail, keeping the same arc and ending beats.

-- ========== THE LAST LETTER (forgiveness) ==========
update public.story_chapters
set body = $$Neither of them could say anymore exactly how it started. That was the strange part — nine years later, if you'd asked either brother to point to the moment everything went wrong, they'd have given you two different answers, and neither would have been the whole truth.

What they agreed on was this: it was a Sunday, their mother's birthday, the kind of dinner that happened every year without anyone having to plan it. The good plates were out. Their father was carving something he'd been proud of all afternoon. And somewhere between the second helping and the coffee, a comment got made — about money, or about their father's health, or about who had shown up more over the years — and it landed wrong.

Marcus said something he thought was a joke. Daniel didn't take it as one. Marcus doubled down instead of walking it back, the way people do when they'd rather be right than kind. Daniel stood up from the table hard enough that his chair scraped the floor, said something short and sharp about how nobody ever had to guess what Marcus really thought of them, and left before dessert.

Their mother cried a little that night, though she wouldn't admit it the next morning. Their father just shook his head and said they'd sort it out, the way brothers always did. He said it every year after that, too, for a while.

What followed wasn't a single decision to stop speaking — nothing so clean as that. It was smaller and slower: a birthday missed on purpose, a text left on read for three days and then not answered at all, a wedding invitation that Daniel sent to the whole family except, unmistakably, to Marcus. Neither of them called to talk about it. Both of them noticed.

By the second year, avoiding each other had become its own kind of routine. They went to the same Thanksgiving at different times. They asked about each other through their mother, carefully, the way you'd ask about a stranger you used to know. "How's Marcus doing?" "He's fine. Busy." Nothing more than that, ever.

There were moments that could have broken it. When their father had his first health scare — a fall, a night in the ER that turned out to be nothing serious — Daniel almost called. He got as far as finding the number before deciding his father would tell him if it were truly bad, and if he called now, out of nowhere, it would look like he only cared because of the timing, like keeping score. He put the phone down and told himself there'd be another moment, a better one, when the reason for calling wouldn't be tangled up with the silence itself.

Marcus had his own almost-moments too — a good year at work he wanted to tell someone who'd actually understand what it took to get there, a night alone in a new apartment when the quiet made him think of being a kid again, sharing a room, arguing over nothing that mattered. Each time, he thought about picking up the phone. Each time, the thought of how strange it would sound after so long — "Hey, it's your brother, I know it's been years" — was enough to put it off one more week, and then one more year.

Their mother stopped asking either of them directly after the third Christmas passed without a word between them. She'd learned, the hard way, that bringing up one brother to the other only shortened the conversation. She kept both their numbers in her phone under their names, no distinguishing marks, as if refusing to acknowledge there was anything unusual about two brothers who hadn't spoken in years.

Nine years is a long time to let a Sunday dinner define two people's relationship. Long enough that new colleagues, new friends, even Daniel's own kids, didn't know he had a brother at all unless someone else mentioned it first. Long enough that the specific words said at that table had blurred and softened in memory, worn down like a stone in a river, until neither of them could have told you exactly what was said — only that it had been enough, at the time, to feel unforgivable.$$
where chapter_number = 1
  and story_id = (select id from public.stories where title = 'The Last Letter');

update public.story_chapters
set body = $$It arrived on a Tuesday, the kind of unremarkable Tuesday that gives no warning about what it's about to hold. Daniel had come home late from work, tired in the specific way that made the mail feel like one more chore rather than anything worth looking forward to — bills, a flyer for a restaurant that had closed two years ago, a card from his dentist's office.

And then, underneath all of it, an envelope with no return address, his name written across the front in handwriting he hadn't seen in nine years but recognized instantly anyway. Some things don't fade the way you expect them to.

He stood in the entryway for a long moment before he opened it, keys still in his other hand, coat still on. Some part of him already knew who it was from before he'd even turned it over. The postmark was from three states away — Marcus had moved, then, at some point in the last nine years, another thing Daniel hadn't known about his own brother.

Inside was a single sheet of paper, folded in thirds, shorter than he expected a letter to be after nine years of silence. No return address, no long explanation, no accounting of who had done what to whom, no apology laid out like evidence in a case Daniel hadn't realized was still open.

Just: "I miss my brother. Call me when you can. — M"

He read it standing in the entryway. Then he read it again sitting at the kitchen table, coat finally off, the letter flat in front of him like something that might disappear if he looked away. He read it a third time before he let himself put it down, and even then he kept glancing back at it, as if the words might have changed, might say something more complicated than what they actually said.

Nine years of reasons not to call — pride, the fear of how strange it would sound, the vague sense that too much time had passed for anything to be salvaged — all of it suddenly felt very hard to explain, even to himself, sitting there with eleven words in his brother's handwriting.

He thought about their mother's birthday dinner, the one that started it all, and found he genuinely could not remember anymore what the actual comment had been, only the shape of the feeling — being talked down to, being dismissed, the particular sting of it coming from someone who was supposed to know him best. Nine years later, the feeling had outlived the memory of its own cause.

He thought about the wedding he hadn't invited Marcus to, a decision that had felt righteous at the time and now, with the letter in front of him, felt small in a way he didn't like admitting.

He thought about his own kids, who'd occasionally asked if they had an uncle, and the vague answer he'd always given — "sort of, it's complicated" — that had never felt like enough of an explanation even as he said it.

He didn't call that night. He told himself it was because it was late, because Marcus was probably asleep by now, because a call like this deserved to be made properly, not rushed at the end of an exhausting day. All of that was true. It was also true that he needed the night to sit with the letter, to let nine years of built-up distance start to soften before he tried to close it.

He propped the letter against the lamp on his nightstand where he'd see it first thing in the morning, half-worried that if he put it away in a drawer, he'd find some new reason to let it wait another year. He fell asleep thinking about his brother's handwriting, unchanged after nearly a decade, and the eleven words that had undone more than a hundred imagined conversations ever could have.$$
where chapter_number = 2
  and story_id = (select id from public.stories where title = 'The Last Letter');

update public.story_chapters
set body = $$He picked up the phone three separate times the next morning before he actually dialed. Twice he got as far as pulling up the number — still saved under "Marcus," no last name, the way it had been since they were teenagers — before setting the phone face-down on the counter and finding something else to do instead. Coffee needed making. Dishes needed washing. Nine years had apparently not cured him of finding small, urgent tasks to avoid a hard conversation.

The third time, he didn't let himself stop to think about it. He dialed before the part of his brain that specialized in reasons-not-to could catch up.

It rang twice. Then a voice that was older than he remembered, but unmistakably the same voice, said, "Hello?"

"It's me," Daniel said, and immediately felt foolish, as if there were any real doubt about who "me" might be, calling from this number, after this many years, one day after a letter with eleven words on it.

There was a pause on the other end — not a cold one, just the sound of someone recalibrating, the way you do when something you've hoped for finally happens and you're not entirely ready for it despite the hoping. "I wasn't sure you'd call," Marcus said finally. "I wasn't sure I would've, either, honestly. If it'd been me getting the letter."

"I almost didn't," Daniel admitted. "I read it about six times first."

They started with safe ground, the way people do — their father's health, which had been fine for a while now, no more scares since that one Daniel had almost called about. Their mother's garden, which Marcus had apparently heard about in more detail than Daniel had, having called her more regularly than Daniel had realized. Small, careful facts, traded back and forth like they were testing the weight the conversation could hold before either of them leaned on it too hard.

Then, without either of them quite deciding to, the conversation loosened. Marcus mentioned a job he'd taken two years back, the kind of thing he would have called Daniel about immediately once, and there was a beat of something like grief in the gap where that call should have happened and hadn't. Daniel told him about his kids, about the older one starting to ask harder questions about the family than "sort of, it's complicated" could keep answering.

Twenty minutes in, they were talking the way they used to — overlapping, interrupting, finishing sentences the other had started, laughing at something that wouldn't have been funny to anyone who hadn't grown up in the same house. It was, against every expectation Daniel had walked into the call with, almost easy.

Neither of them brought up the dinner. Neither of them brought up the nine years, not directly — not the missed wedding, not the birthday cards that stopped coming, not the specific comment that had started all of it, which Daniel still couldn't fully remember and, he realized somewhere around the thirty-minute mark, no longer needed to. Some things, it turned out, didn't require the full accounting to be set down. They just required someone to go first.

Before they hung up, Marcus said, quieter than the rest of the call had been, "I really did just want to see if we still had this. Whatever this is."

"We still have it," Daniel said, and found he meant it more than he'd expected to when he'd first seen the letter propped against his lamp the night before.

They talked about getting together soon, properly, with their parents there to see it — no fixed date yet, but the kind of plan that felt real rather than polite. When Daniel finally set the phone down, the quiet of his kitchen felt different than it had the day before. Nine years is a long silence. It turned out to need only one sentence to end.$$
where chapter_number = 3
  and story_id = (select id from public.stories where title = 'The Last Letter');

-- ========== THE COMMUNITY GARDEN (hope) ==========
update public.story_chapters
set body = $$The lot had been fenced off for so long that most people on the block had stopped seeing it entirely — the kind of empty space that becomes part of the scenery, mentioned only when visitors asked what used to be there and nobody could quite remember anymore.

It had been a corner store once, decades back, and then briefly an auto shop, and then nothing at all after a fire nobody talked about in much detail. The building came down not long after. What was left was a rectangle of cracked concrete and stubborn weeds, boxed in by chain-link that had rusted to the color of old pennies, a padlock on the gate that had probably been changed once or twice over the years by a city that had otherwise forgotten the place existed.

Six years of that. Six years of broken glass catching the light at certain times of day, six years of the same three shopping carts slowly getting buried under weeds that grew taller each summer, six years of a chain-link fence doing the one job anyone still cared about it doing, which was keeping people out of a space nobody had found a use for.

Rosa noticed it every day walking her daughter to school, the way you notice something without really seeing it. Dennis noticed it from his porch two doors down, where he'd sit some evenings with a coffee that had gone cold an hour before he remembered to drink it. Yusuf noticed it because his apartment window looked directly onto it, and some nights the streetlight through the chain-link threw a shadow pattern across his ceiling that he'd stopped finding strange only because he'd stopped really looking at it.

The three of them had exchanged nothing more than waves for years — the kind of nodding familiarity that comes from sharing a block without sharing anything else. It was Rosa, waiting at a stop sign with Dennis one evening while a slow line of cars passed, who said it first, half as a joke: "Somebody ought to just take that fence down and plant something in there." Dennis laughed, the way you laugh at something you don't expect to go anywhere. Then he stopped laughing and said, "You know, I actually don't know why nobody has."

It took a month of phone calls to find out. The lot, it turned out, technically belonged to the city, inherited through some tax default years back and then filed away and forgotten in the way that unglamorous municipal property often is. There was no active plan for it, no development on the books, nothing standing in the way except the fact that nobody had ever asked.

Rosa made the first call, mostly out of stubbornness once she'd started. She got transferred four times before she found someone in the parks department who seemed to actually know what she was talking about, and even then it took another three weeks of follow-up emails before anyone would commit to anything. Dennis went to a community board meeting neither of them had ever attended before, sat through ninety minutes of unrelated business to get two minutes at the end to make the case. Yusuf, who worked in a hardware store and had opinions about soil that neither of the other two had expected, started drafting an actual plan — what could grow there, what the lot would need, how much it might cost to make usable.

The city clerk who finally handed over the key seemed almost bemused by the whole request, as if community gardens were an idea from a decade she vaguely remembered being popular once. "It's yours," she said, sliding a single brass key across the counter. "Try not to hurt yourselves on the glass in there."

Getting the key changed less than any of them expected it to, and more than they were ready for. The lock still stuck. The gate still groaned like it hadn't opened in years, which it hadn't. But standing just inside it for the first time — three people who'd shared nothing but a nodding acquaintance a month before — none of them said much of anything for a while. There was a lot of work ahead, and none of it was going to be quick.$$
where chapter_number = 1
  and story_id = (select id from public.stories where title = 'The Community Garden');

update public.story_chapters
set body = $$Clearing the lot took longer than any of them had guessed, and none of them had guessed it would be quick. The weeds came out first, root systems deeper and more stubborn than seemed reasonable for plants nobody had ever watered on purpose. Underneath them was worse: broken concrete in slabs too heavy to lift without a truck, the three shopping carts rusted enough that they came apart in pieces rather than being wheeled out whole, and, near what must have once been the back corner of the old auto shop, a scatter of nails and glass fine enough that Yusuf insisted on a full second pass with a magnet on a stick before anyone brought a child near the place.

Two weekends in, they had cleared maybe a third of it, and Dennis, sunburned and sore in muscles he hadn't used in years, said what all three of them were quietly thinking: "I did not know this was going to be a full-time job."

They argued more than any of them expected to, for people who'd started this as a favor to the neighborhood rather than to each other. Rosa wanted flowers along the fence line, something that would make the place look cared for from the street. Yusuf wanted every inch of usable soil going to vegetables, arguing that a garden that didn't feed anyone wasn't much of a garden. Dennis, mostly, wanted to stop arguing and start planting something, anything, before the season got away from them entirely. They compromised in the way people do when nobody's fully satisfied — flowers along the fence, vegetables in the middle, a patch near the gate left undecided because none of them had the energy left to fight about it.

They planted late, later than any of the gardening books Yusuf had checked out from the library recommended, and it showed. A heat wave arrived three weeks after the first seedlings went into the ground, ten straight days over ninety degrees that none of them had seen coming and none of the young plants were ready for. Rosa came by every morning before work to water, and every evening after, and still lost half of what she'd planted along the fence. Yusuf's careful vegetable rows fared a little better, but only a little. Dennis, checking on things one particularly brutal afternoon, found himself standing in the dead center of the lot saying something not especially polite to a sky that wasn't listening.

Other neighbors watched all of this with open skepticism. A man two houses down told Rosa, not unkindly, that he gave the whole project until the first frost before everyone lost interest. A woman walking her dog past the fence most mornings asked, more than once, whether they knew what they were doing, in a tone that suggested she suspected they didn't. Rosa didn't entirely disagree with her, some days.

But something else was happening alongside the losses, slower and less visible than a heat wave. The group chat the three of them had started just to coordinate watering schedules had grown, without anyone quite deciding to add people, to include six other neighbors who'd started stopping by to help without being asked — an older man who turned out to know more about composting than any of them, two teenagers from down the block who liked having something to do after school, a woman who brought lemonade some Saturdays and stayed to pull weeds once she'd delivered it.

By the end of that first season, there wasn't much to point to in the lot itself. A few surviving vegetable plants, some flowers along a fence line, a lot of bare dirt where things hadn't made it. Sore backs, sunburn, a season's worth of arguments about spacing and watering schedules. What there was, that hadn't been there in June, was a list of nine names in a phone that had started as three, and a habit, hard-won, of showing up.$$
where chapter_number = 2
  and story_id = (select id from public.stories where title = 'The Community Garden');

update public.story_chapters
set body = $$Nobody had expected much from the second spring, not after how the first season had gone. Rosa, if she was honest, had gone into it bracing for another summer of losses, another round of the man two houses down reminding her he'd predicted this would fizzle out.

Instead, the tomatoes came up almost too easily, as if the ground itself had needed a full year to recover from being forgotten for six. Rows planted by people who, twelve months earlier, hadn't known each other's names came in thick enough that there was surplus to give away before June was even over — bags of them left on porches up and down the block, more than the nine names in the group chat could use themselves.

Word spread the way it does on a block where everyone's paying more attention to each other than they used to. The man who'd given the project until the first frost showed up one Saturday with a shovel he'd apparently owned the whole time, offering to help expand the vegetable rows before anyone had to ask him twice. The woman who walked her dog past the fence started stopping instead of just passing, then started bringing seedlings from her own yard to add to the mix.

Kids from the block began stopping by after school not because anyone had organized an activity for them, but because the garden had become, without any planning, the most interesting thing within walking distance — a place with dirt to dig in, tomatoes worth checking on, and, on the better afternoons, someone willing to explain why the squash plants were doing that strange thing with their leaves.

Dennis, who'd once stood in the middle of a dead lot cursing at a heat wave, found himself most evenings now sitting on an upturned crate near the gate instead of on his own porch, coffee going cold in his hand the same as always, except now there were usually two or three other people there to talk to while it did.

Yusuf's insistence on vegetables over flowers had, in the end, mostly won out, though Rosa's fence line bloomed thick enough by midsummer that even Yusuf admitted it made the whole place look less like a construction site and more like somewhere you'd want to be. The undecided patch near the gate, left unplanted the year before out of sheer exhaustion, became a bench area — two mismatched chairs and a low table someone's father had built, the closest thing the garden had to a formal gathering spot.

The fence gate itself stopped getting locked during the day sometime that second summer, propped open with a brick nobody remembered placing there and nobody bothered to remove. It just seemed to belong that way now, the way certain small arrangements settle into a place once enough people agree, without discussion, that they work.

None of it looked like much from the street, if you were the kind of person who measured a garden by how it photographed. Uneven rows, a fence with paint that had chipped the first winter and never gotten touched up, tomato cages that leaned at odd angles from the weight of what they were holding up. But it was full, most afternoons, in a way the lot had never been full of anything in the six years before three neighbors decided to ask for a key.

Rosa still thinks about that stop sign conversation sometimes, the half-joke that started all of it — somebody ought to just take that fence down. She hadn't meant it as a plan. Neither had Dennis, laughing at first before he stopped laughing. It had taken a full season of failure before anything worked, and even then, what grew wasn't really about the tomatoes.$$
where chapter_number = 3
  and story_id = (select id from public.stories where title = 'The Community Garden');

-- ========== THE CROSSING GUARD (everyday_heroes) ==========
update public.story_chapters
set body = $$She took the job the year her youngest started kindergarten, meaning to do it for a season or two — a little extra money, a reason to already be near the school when the day ended, something to fill the strange new quiet of mornings once all three of her kids were finally old enough for class. Twenty-two years later, she was still there, and the youngest who'd started it all had kids of his own now, crossing different streets in a different part of town.

The corner itself hadn't changed much in all that time, not really — a four-way intersection two blocks from the elementary school, busier than it looked on a map because it caught the overflow from a bigger road half a mile down. Cars came through faster than the speed limit technically allowed, especially in the first stretch of morning before the school buses slowed everyone down out of necessity. It was, by any reasonable measure, not a glamorous corner to spend three hours of your morning and two of your afternoon standing on, in all weather, for over two decades.

She learned early that the job was mostly about being visible and being early. Fifteen minutes before the first kids usually arrived, rain or shine or the handful of genuinely brutal winters that stretch of the country occasionally produced, she was out there in her vest, flag in hand, orange bright enough to see through fog on the worst mornings. She kept a folding umbrella clipped to her bag for years before finally investing in a proper rain poncho, after a particularly memorable September storm that soaked through three layers before the first bell even rang.

The first year was the hardest, in ways she hadn't expected going in. She didn't know any of the kids yet, didn't know which ones would dart ahead of a parent's hand the second they saw a friend on the other side, didn't know the rhythms of the corner — which mornings the buses ran late, which drivers cut the corner too close on their way to work, which kids needed a little extra time getting across because of a limp or a heavy backpack or just being small for their age. She learned all of it slowly, the way you learn anything by simply doing it every day until it stops being unfamiliar.

By the second year, she knew most of the regulars by sight even before she knew their names — the tall boy who always ran the last twenty feet no matter how many times she reminded him not to, the pair of sisters who walked at exactly the same pace every single morning like they'd rehearsed it, the quiet kid who hung back at the edge of the group and crossed last, every day, like he was in no hurry to get where the day was taking him.

She started learning names properly around the third year, once it became clear this wasn't a temporary arrangement — first names, and eventually, for the families who'd been on the route long enough, younger siblings' names too, learned before the sibling was even old enough to walk to school themselves. Parents started recognizing her as a fixture rather than a stranger doing a job, would slow down to roll a window down and say good morning, would occasionally stop to ask if she'd noticed anything about their kid that they should know about.

She hadn't expected that part of it, honestly — being trusted with more than just getting children safely across a street. But it made a kind of sense the longer she did it. She was there every single morning, watching the same faces, in a way that even attentive parents sometimes weren't, caught up as they were in getting everyone out the door on time. She noticed things almost by accident: a kid who seemed a little slower to smile than usual, a backpack carried like it weighed more than it should, a flinch at a car horn that seemed sharper than the moment called for.

Nobody trained her to watch for any of that. It wasn't in whatever brief orientation the district had given her twenty-two years earlier, a single afternoon covering hand signals and liability forms. She just did it, the way you do anything you care about long enough — not because someone asked, but because you're already standing there, already paying attention, and it would take more effort to look away than to keep noticing.$$
where chapter_number = 1
  and story_id = (select id from public.stories where title = 'The Crossing Guard');

update public.story_chapters
set body = $$There was a boy, early on in her second decade at the corner, who started showing up some mornings in the same shirt he'd worn the day before, quieter than she remembered him being at the start of the school year. She didn't say anything the first time, or the second. By the third, she found herself asking, gently, if everything was okay at home — not prying, just leaving a door open in case he wanted to walk through it.

He didn't, not that morning. But two weeks later, waiting for a gap in traffic, he mentioned almost sideways that his dad had moved out, that mornings were different now, that his mom cried sometimes before he left for school and he didn't always know what to say to her. She listened, mostly, the way you listen to a kid who needs to say something out loud more than he needs an answer back. She told the school counselor what he'd shared, carefully, in the vaguest terms that still got the right people paying attention, and never mentioned to the boy that she'd done it. He seemed steadier within a few weeks. She never knew exactly what had changed, only that something had, and she liked to think her small nudge had been some part of it.

There were other names, other mornings, that stayed with her over the years in the same way. A girl who went quiet and watchful for a stretch one winter, until it came out — not to the crossing guard directly, but through a friend who'd mentioned it, worried — that things had gotten difficult at home in a way that needed more than a kind word at a crosswalk. A boy who started arriving without breakfast some mornings, which she noticed because he'd get lightheaded waiting at the corner some days, and which she solved, quietly, by keeping a box of granola bars in her bag for a full year until whatever situation had caused it resolved itself.

None of these interventions were dramatic. She never called anyone a hero for any of it, least of all herself. What she did, mostly, was notice, and then say something small and low-stakes enough that a kid or a parent could take it or leave it without feeling exposed. "Everything okay?" cost nothing to ask and cost nothing to answer honestly or not, and she'd learned, over enough mornings, exactly how to ask it so that it didn't feel like an interrogation.

She kept a mental list of which kids needed extra time, which ones needed a joke to get them smiling before the school day started, which ones needed to be left entirely alone because attention, even kind attention, made things worse for them some mornings. She adjusted, corner by corner, kid by kid, year by year, a curriculum nobody had ever handed her and that she'd built entirely out of paying closer attention than the job strictly required.

Parents noticed, eventually, in ways that surprised her. A mother stopped one morning to thank her specifically for asking her son about a rough patch the family had gone through, saying it had meant more to him than anyone at home had realized at the time. A father, dropping his daughter off on what turned out to be his last day before a deployment, asked her directly to keep an extra eye on his kid while he was away, as if she were as much a part of the family's safety net as anyone else in the neighborhood.

She'd started the job twenty-two years earlier thinking of it as a way to stand near a school for a few hours a day. Somewhere in the middle of all those mornings, it had become something closer to a form of quiet, unofficial care for an entire generation of kids on that block — noticed, one crosswalk at a time, by someone whose actual job description had never once mentioned any of it.$$
where chapter_number = 2
  and story_id = (select id from public.stories where title = 'The Crossing Guard');

update public.story_chapters
set body = $$She'd expected her last morning to be quiet, mostly — a final wave at the corner, maybe a small cake in the school office if anyone remembered to organize one, and then the strange, sudden absence of a routine that had shaped every single school-year morning of her adult life.

Instead, she arrived at her usual time, fifteen minutes before the first kids, to find nearly two dozen people already gathered at the corner, spilling onto both sidewalks in a way that made the crossing itself briefly more complicated than usual. Some of them were current parents she saw every day. Many of them were not.

There was a young man in his late twenties, someone she recognized after a moment as the boy who used to run the last twenty feet every single morning no matter how many times she told him not to, now with a toddler of his own on his hip, waiting to cross that same corner for the first time. There were the two sisters, grown now, who'd walked at exactly the same pace for years and apparently still moved in step with each other crossing the street as adults. There was the quiet boy who'd always hung back and crossed last — taller now, more confident in the way he carried himself, holding a card he'd clearly made himself rather than bought.

She hadn't told anyone the date of her last day beyond the school office. Someone, it turned out, had asked around, and word had traveled the way it does in a neighborhood that had spent over two decades getting used to her being a fixture rather than an employee doing a job.

The cards came one at a time, more of them than she could read through in the twenty minutes before the first bell actually rang. Most were simple — thank-yous, a few drawings of a woman in an orange vest with a flag, the specific visual signature of someone who'd been drawn by children for over twenty years running. A few were longer, written by the parents rather than the kids: notes about a hard year that had gotten a little easier because someone showed up every morning and noticed when things weren't right, notes about a specific conversation at the corner that had mattered more than she'd realized at the time it happened.

The boy who used to come to school without breakfast, now a father himself, told her directly, in front of everyone, about the granola bars she'd kept in her bag that year — a detail she'd genuinely forgotten until he said it, and one he clearly never had. "I don't think you knew how bad things were at home that year," he said. "But you fed me anyway, every morning, and never made it a thing."

She didn't have much of a speech ready, hadn't expected to need one. She said something simple instead, close to what she'd have said on any ordinary morning at that corner: that she was glad she'd gotten to know all of them, that watching them grow up one crossing at a time had been the best part of a job most people assumed was small.

Someone asked, near the end, whether she had any advice for whoever took over the corner next. She thought about it for a moment, flag still in her hand out of twenty-two years of habit, and said the only thing that felt true: learn their names as fast as you can, and then just keep showing up.

Most people, she knows, don't notice a crossing guard at all — a fixture at the edge of a school morning, easy to drive past without a second glance. For twenty-two years, standing at that same corner, she'd made a quiet practice of noticing every single one of them back. On her last morning there, it turned out, they'd all been noticing her too.$$
where chapter_number = 3
  and story_id = (select id from public.stories where title = 'The Crossing Guard');
