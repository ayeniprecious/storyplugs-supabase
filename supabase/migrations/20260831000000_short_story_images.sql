-- Real cover images for the 5 seed short stories, which predate
-- is_short_story (20260830000000) and shipped with image_url = null.
-- Free-to-use Unsplash photos, chosen to match each story's scene.
update public.stories
set image_url = 'https://images.unsplash.com/photo-1748525874315-4197e3c30bf6?w=1200&q=80&auto=format&fit=crop'
where title = 'The Umbrella';

update public.stories
set image_url = 'https://images.unsplash.com/photo-1533777857889-4be7c70b33f7?w=1200&q=80&auto=format&fit=crop'
where title = 'Table for One';

update public.stories
set image_url = 'https://images.unsplash.com/photo-1512358958014-b651a7ee1773?w=1200&q=80&auto=format&fit=crop'
where title = 'The Spare Key';

update public.stories
set image_url = 'https://images.unsplash.com/photo-1669671943625-e20799ee5f42?w=1200&q=80&auto=format&fit=crop'
where title = 'New Shoes';

update public.stories
set image_url = 'https://images.unsplash.com/photo-1570793005299-c091be91bbad?w=1200&q=80&auto=format&fit=crop'
where title = 'The Long Way Home';
