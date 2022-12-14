SELECT * FROM mavenfuzzyfactory.website_sessions;


-- -------------------------------------------------------------------------------------------------------------------------------------
--                                                     MID COURSE PROJECT
-- -------------------------------------------------------------------------------------------------------------------------------------
--                              Message from CEO Cindy
-- Good morning, I need some help preparing a presentation for the board meeting next week. #
-- The board would like to have a better understanding of our growth story over our first 8 months.
-- This will also be a good excuse to show off our analytical capabilities a bit. -Cindy

-- YOUR OBJECTIVES: 
  -- Tell the story of your company’s growth, using trended performance data 
  -- Use the database to explain some of the details around your growth story, and quantify the revenue impact of some of your wins
  -- Analyze current performance, and use that data available to assess upcoming opportunities
  
  -- --------------- MID COURSE QUESTIONS
      -- 1. Gsearch seems to be the biggest driver of our business. 
			-- Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there? 

	  -- 2.	Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand 
            -- and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 

      -- 3.	While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type?
            -- I want to flex our analytical muscles a little and show the board we really know our traffic sources. 

      -- 4.	I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
            -- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?


-- STEP 1: Find the first website_session_id for relevant sessions.
-- STEP 2: Identify the landing page url of each session.
-- STEP 3: Counting pageviews for each session, to identify "bounces". 
 -- (If have more than one pageview then its a non-bounce  but only on landing page but did nothing elas, its a bounce)
-- STEP 4: Summarizing total sessions and bounced sessions by Landing page.

  
  

SELECT * FROM mavenfuzzyfactory.website_sessions;

select * from website_sessions limit 3;  -- CEO sent email on November 27, 2012 which is 2012-11-27

select * from orders limit 3;

select date_sub('2012-11-27', Interval 8 month);  -- got 2012-03-27 maybe pick 

select min(created_at) from website_sessions where utm_source='gsearch' and utm_campaign='brand'; -- 2012-03-19 it started 

select utm_campaign from website_sessions where utm_source='gsearch' group by utm_campaign;

-- 1   ------------------- Monthly trend for gsearch nonbrand from March to November   ----------------------------

select
monthname(date(created_at)),
-- month(date(created_at)),
count(distinct website_session_id) as sessions
from website_sessions
where created_at >='2012-03-19' and created_at < '2012-11-27'
and website_sessions.utm_source='gsearch'
 and website_sessions.utm_campaign='nonbrand'
group by monthname(date(created_at))
order by sessions  desc;


-- Lets join with order now 

select
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as Month,   -- can do " monthname(website_sessions.created_at) as Month " but i like month names
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders_now
-- count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate (can add it or not)
from website_sessions
left join orders
on orders.website_session_id= website_sessions.website_session_id
where website_sessions.created_at < '2012-11-27'
and website_sessions.utm_source='gsearch'
group by 1,2;

-- Executed
# yr	Month	sessions	orders_now
# 2012	3			1860	60
# 2012	4			3574	92
# 2012	5			3410	97
# 2012	6			3578	121
# 2012	7			3811	145
# 2012	8			4877	184
# 2012	9			4491	188
# 2012	10			5534	234
# 2012	11			8889	373


-- From our findings, the order volume from March to November is 4 times more. The session is also increase month by month.


-- 2   -----------  Monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately.
            -- This shows if the brand is getting attention without using paid traffic

select
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as Month,
-- website_sessions.utm_campaign,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct case when utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as nonbrand_session,
count(distinct case when utm_campaign = 'nonbrand' then orders.order_id else null end) as nonbrand_orders,
count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_session,
count(distinct case when utm_campaign = 'brand' then orders.order_id else null end) as brand_orders
from website_sessions
left join orders
on orders.website_session_id=website_sessions.website_session_id
where website_sessions.created_at < '2012-11-27' 
and website_sessions.utm_source = 'gsearch'
group by 1,2;

-- Executed

# yr	Month	sessions	nonbrand_session	nonbrand_orders	brand_session	brand_orders
# 2012	3		1860		1852					60				8				0
# 2012	4		3574		3509					86				65				6
# 2012	5		3410		3295					91				115				6
# 2012	6		3578		3439					114				139				7
# 2012	7		3811		3660					136				151				9
# 2012	8		4877		4673					174				204				10
# 2012	9		4491		4227					172				264				16
# 2012	10		5534		5197					219				337				15
# 2012	11		8889		8506					356				383				17

-- Brand campaigns are visitors using "search engine" and looking particularly for your brand. CEO is looking for the brand.
   -- The brand increased over the months. 
   
   
-- 3 -- Dive into nonbrand, pull Monthly sessions and order split by device type--  Traffic source

-- 3 --- Monthly sessions and orders by device type

select
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as Month,
-- website_sessions.device_type,
-- count(distinct website_sessions.website_session_id) as sessions,
count(distinct case when device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_session,
count(distinct case when device_type = 'desktop' then orders.order_id else null end) as desktop_orders,
count(distinct case when device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile_session,
count(distinct case when device_type = 'mobile' then orders.order_id else null end) as mobile_orders
-- count(distinct orders.order_id) as orders_now,
-- count(distinct orders.order_id)/count(distinct case when device_type = 'desktop' then website_sessions.website_session_id else null end)
-- as order_rt_dtop,
-- count(distinct orders.order_id)/count(distinct case when device_type = 'mobile' then website_sessions.website_session_id else null end)
-- as order_rt_mobile
-- count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate
-- week(website_sessions.created_at)
from website_sessions
left join orders
on orders.website_session_id= website_sessions.website_session_id
where website_sessions.created_at < '2012-11-27'
and website_sessions.utm_source='gsearch'
 and website_sessions.utm_campaign='nonbrand'
group by 1,2;

-- Executed
# yr	Month	desktop_session	desktop_orders	mobile_session	mobile_orders
# 2012	3			1128			50				724			10
# 2012	4			2139			75				1370		11
# 2012	5			2276			83				1019		8
# 2012	6			2673			106				766			8
# 2012	7			2774			122				886			14
# 2012	8			3515			165				1158		9
# 2012	9			3171			155				1056		17
# 2012	10			3934			201				1263		18
# 2012	11			6457			323				2049		33




-- 4 ---- Monthly trend for Gsearch and other channels

select distinct utm_source, utm_campaign, http_referer
 from website_sessions 
 where website_sessions.created_at < '2012-11-27'; 
      
-- Executed

# utm_source	utm_campaign	http_referer
# gsearch			nonbrand	https://www.gsearch.com
# null				null		null                     (all null is direct type traffic)
# gsearch			brand		https://www.gsearch.com
# null				null 		https://www.gsearch.com   (source and campaign are null but have referer, its "ORGANIC SEARCH TRAFFIC)
# bsearch			brand		https://www.bsearch.com
# null				null 		https://www.bsearch.com    (source and campaign are null but have referer, its "ORGANIC SEARCH TRAFFIC)
# bsearch		nonbrand		https://www.bsearch.com

-- The paid parameters are "source" and "campaign" then we have referer, its coming from search engine but not tag to paid parameters
  -- this is easy to identify as "ORGANIC SEARCH TRAFFIC". It does not have page tracking parameter associated/linked to them.

select
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as Month,
count(distinct case when utm_source = 'gsearch' then website_sessions.website_session_id else null end) as gsearch_paid_session,
count(distinct case when utm_source = 'bsearch' then website_sessions.website_session_id else null end) as bsearch_paid_session,
count(distinct case when utm_source IS NULL AND http_referer IS NOT NULL then website_sessions.website_session_id else null end) 
as organic_search_sessions,
count(distinct case when utm_source IS NULL AND http_referer IS NULL then website_sessions.website_session_id else null end) 
as direct_type_in_sessions
from website_sessions
left join orders
on orders.website_session_id= website_sessions.website_session_id
where website_sessions.created_at < '2012-11-27'
group by 1,2;

-- Executed 
# yr	Month	gsearch_paid_session	bsearch_paid_session	organic_search_sessions	direct_type_in_sessions
# 2012	3			1860					2							8						9
# 2012	4			3574					11							78						71
# 2012	5			3410					25							150						151
# 2012	6			3578					25							190						170
# 2012	7			3811					44							207						187
# 2012	8			4877					705							265						250
# 2012	9			4491					1439						331						285
# 2012	10			5534					1781						428						440
# 2012	11			8889					2840						536						485


-- Sessions that are not paid for are Organic and direct_type. CEO would be happy that these channels are growing. 
-- using paid channels, we think of cost per acqusition of customer. If that can reduce and unpaid channels sessions increase,
-- it will save the company some money from paying campaigns/ ads.



-- 5 ----------------------------- Website performance over 8 months ------------------
     -- Pull session to order conversion rates by month
select
year(website_sessions.created_at) as yr,
month(website_sessions.created_at) as Month,
-- monthname(website_sessions.created_at) as Month_name,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate
from website_sessions
left join orders
on orders.website_session_id= website_sessions.website_session_id
where website_sessions.created_at < '2012-11-27' 
group by 1,2;

-- Executed

# yr	Month	sessions	orders_now	conv_rate
#2012	3	1879	60	0.0319
#2012	4	3734	99	0.0265
#2012	5	3736	108	0.0289
#2012	6	3963	140	0.0353
#2012	7	4249	169	0.0398
#2012	8	6097	228	0.0374
#2012	9	6546	287	0.0438
#2012	10	8183	371	0.0453
#2012	11	12750	561	0.0440


-- 6 --- Estimate the REVENUE that test earned us (Hint: increase from the test Jun 19 -28)
		-- Use nonbrand sessions and revenue since to calculate incremental value
        -- Gsearch lander test.
        
select
min(website_pageview_id) as first_test_pv
from website_pageviews
where pageview_url = '/lander-1';

-- Executed
# first_test_pv
#   23504

create temporary table first_test_pageview
select 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pageview_id -- helps us pick the first page of a user.
-- count(distinct website_pageviews.website_session_id) as sessions,
from website_pageviews
inner join website_sessions
on website_sessions.website_session_id = website_pageviews.website_session_id
-- where website_pageviews.pageview_url = '/lander-1'
and website_sessions.created_at < '2012-07-28'  -- gotten from the assignment
and website_pageviews.website_pageview_id >= 23504 -- the min_pageviewid found on 2012-06-19 for "/lander-1"
and utm_source ='gsearch'
and utm_campaign= 'nonbrand'
group by 
website_pageviews.website_session_id;


select * from first_test_pageview limit 5;   -- checking on the table

-- NEXT: PICKING THE LANDING PAGE AND REFERS TO NONBRAND CAMPAIGN

create temporary table nonbrand_test_sessions_w_landing_pages
select first_test_pageview.website_session_id,
website_pageviews.pageview_url as landing_page
from first_test_pageview
left join website_pageviews
on website_pageviews.website_pageview_id = first_test_pageview.min_pageview_id
where website_pageviews.pageview_url IN ('/home','/lander-1');  -- can use where here

select * from nonbrand_test_sessions_w_landing_pages limit 5;   -- checking on the table

-- NEXT: IS TO LEFT JOIN TO ORDERS

create temporary table nonbrand_test_sessions_w_orders
select
nonbrand_test_sessions_w_landing_pages.website_session_id,
nonbrand_test_sessions_w_landing_pages.landing_page,
orders.order_id as order_id
from nonbrand_test_sessions_w_landing_pages
left join orders
   on orders.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id;
   
select * from nonbrand_test_sessions_w_orders;

-- Executed
    -- some order_id were null and some had values
    

-- NEXT pulling from the nonbrand_test_sessions_w_orders table
select 
landing_page,
count(distinct website_session_id) as session,
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_session_id) as conv_rate
from nonbrand_test_sessions_w_orders
group by 1;
    
-- Executed
# landing_page	session		orders		conv_rate
# /home			2261		72				0.0318
# /lander-1		2316		94				0.0406
    
-- 0.0318 (3.18%) for /home and 0.0406 (4.06%) for /lander-1
-- 0.0088 were additional order per session (0.88%).  0.0088 is the incremental converison value or rate 
    
-- Next is to find the most recent pageview for gsearch nonbrand where thetraffic was sent to /home

select
max(website_sessions.website_session_id) as most_recent_gsearch_nonbrand_home_pageview
from website_sessions
left join website_pageviews
on website_pageviews.website_session_id = website_sessions.website_session_id
where utm_source= 'gsearch'
and utm_campaign='nonbrand'
and pageview_url='/home'
and website_sessions.created_at < '2012-11-27';

# Executed
-- max_website_session_id (most_recent_gsearch_nonbrand_home_pageview)  = 17145
-- This was the maximum traffic volume to the "/home" before traffic was re-routed to home and lander-1.
    
    
select
  count(website_session_id) as sessions_since_test
from website_sessions
where created_at < '2012-11-27'
   and website_session_id > 17145 -- last "/home" session
   and utm_source='gsearch'
   and utm_campaign='nonbrand';
   
-- Since the test, the session_since_test = 22972
#   since the website session after the test was 22,972, 
#   we multiply with 0.0088 incrementsl orders since test concluded on 29th July
# ie 2012-07-29. from that date to 29th Nov is roughly 4 months. do 22972 x 0.0088 = 202.15
# This means that we had 202.15 / 4 months = 50.53 ~ 50 extra orders each month


/*
7. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/

-- ------------------------------- STEPS TO FOLLOW ----------------------------------------------------------------
-- STEP 1: Select all pageviews for relevant sessions
-- STEP 2: Identify each relevant pageview as the specific funnel step
-- STEP 3: Create the session-level conversion funnel view
-- STEP 4: Aggregate the data to assess funnel performance

select * from website_pageviews limit 5;  -- we need /home and /lander-1

select 
website_sessions.website_session_id, -- remember the session_id is the id of users
website_pageviews.pageview_url,      -- and the different pages the users landed on and used
-- website_pageviews.created_at as pageview_created_at, -- with the time on these pages
case when pageview_url='/home' then 1 else 0 end as homepage,
case when pageview_url='/lander-1' then 1 else 0 end as custom_lander,
case when pageview_url='/products' then 1 else 0 end as products_page,    -- these CASE WHEN gives us flags of 0 or 1.
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page,
case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
case when pageview_url='/billing'then 1 else 0 end as billing_page,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews -- '/billing','/thank-you-for-your-order'
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at >= '2012-06-19'  -- asked by website manager
and website_sessions.created_at  < '2012-07-28' -- date website manager requested by email
and website_sessions.utm_source ='gsearch'
and website_sessions.utm_campaign= 'nonbrand'
and website_pageviews.pageview_url IN 
('/home','/lander-1', '/products', '/the-original-mr-fuzzy', '/cart','/shipping', '/billing','/thank-you-for-your-order')
 -- date website manager requested by email
order by 
website_sessions.website_session_id,   -- order by the users id and time the users were in the pages.
website_pageviews.created_at;

# Executed (I just limited to get a view of this)
# website_session_id  pageview_url	homepage custom_lander	products_page mrfuzzy_page cart_page shipping_page billing_page	thankyou_page
#11683	/lander-1	0	1	0	0	0	0	0	0
#11684	/home		1	0	0	0	0	0	0	0
#11685	/lander-1	0	1	0	0	0	0	0	0
#11686	/lander-1	0	1	0	0	0	0	0	0
#11686	/products	0	0	1	0	0	0	0	0
#11687	/home		1	0	0	0	0	0	0	0


-- Then to get the max, we use a subquery

select
	website_session_id,
	max(homepage) as saw_homepage,
	max(custom_lander) as saw_custom_lander,
	max(products_page) as products_made_it,
	max(mrfuzzy_page) as mrfuzzy_made_it,
	max(cart_page) as cart_made_it,
	max(shipping_page) as shipping_made_it,
	max(billing_page) as billing_made_it,
	max(thankyou_page) as thankyou_made_it
from(
select 
website_sessions.website_session_id, -- remember the session_id is the id of users
website_pageviews.pageview_url,      -- and the different pages the users landed on and used
-- website_pageviews.created_at as pageview_created_at, -- with the time on these pages
case when pageview_url='/home' then 1 else 0 end as homepage,
case when pageview_url='/lander-1' then 1 else 0 end as custom_lander,
case when pageview_url='/products' then 1 else 0 end as products_page,    -- these CASE WHEN gives us flags of 0 or 1.
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page,
case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
case when pageview_url='/billing'then 1 else 0 end as billing_page,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews -- '/billing','/thank-you-for-your-order'
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at >= '2012-06-19'  -- asked by website manager
and website_sessions.created_at  < '2012-07-28' -- date website manager requested by email
and website_sessions.utm_source ='gsearch'
and website_sessions.utm_campaign= 'nonbrand'
and website_pageviews.pageview_url IN 
('/home','/lander-1', '/products', '/the-original-mr-fuzzy', '/cart','/shipping', '/billing','/thank-you-for-your-order')
 -- date website manager requested by email
order by 
website_sessions.website_session_id,   -- order by the users id and time the users were in the pages.
website_pageviews.created_at)
as pageview_level
Group by
	website_session_id;

-- We get from the code up if the user id saw the home page or the custom_lander page. 
-- we use "saw_homepage" and "saw_custom_lander " to create summaries.


######## USE A TEMPORARY TO STORE OUR RESULTS

create temporary table session_level_made_it_flagged
select
	website_session_id,
	max(homepage) as saw_homepage,
	max(custom_lander) as saw_custom_lander,
	max(products_page) as products_made_it,
	max(mrfuzzy_page) as mrfuzzy_made_it,
	max(cart_page) as cart_made_it,
	max(shipping_page) as shipping_made_it,
	max(billing_page) as billing_made_it,
	max(thankyou_page) as thankyou_made_it
from(
select 
website_sessions.website_session_id, -- remember the session_id is the id of users
website_pageviews.pageview_url,      -- and the different pages the users landed on and used
-- website_pageviews.created_at as pageview_created_at, -- with the time on these pages
case when pageview_url='/home' then 1 else 0 end as homepage,
case when pageview_url='/lander-1' then 1 else 0 end as custom_lander,
case when pageview_url='/products' then 1 else 0 end as products_page,    -- these CASE WHEN gives us flags of 0 or 1.
case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
case when pageview_url='/cart' then 1 else 0 end as cart_page,
case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
case when pageview_url='/billing'then 1 else 0 end as billing_page,
case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews -- '/billing','/thank-you-for-your-order'
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at >= '2012-06-19'  -- asked by website manager
and website_sessions.created_at  < '2012-07-28' -- date website manager requested by email
and website_sessions.utm_source ='gsearch'
and website_sessions.utm_campaign= 'nonbrand'
and website_pageviews.pageview_url IN 
('/home','/lander-1', '/products', '/the-original-mr-fuzzy', '/cart','/shipping', '/billing','/thank-you-for-your-order')
 -- date website manager requested by email
order by 
website_sessions.website_session_id,   -- order by the users id and time the users were in the pages.
website_pageviews.created_at)
as pageview_level
Group by
	website_session_id;


select * from session_level_made_it_flagged limit 5; -- check the table

-- Then we use "CASE STATEMNT TO PRODUCE SUMMARY 

select
	case 
		when saw_homepage = 1 THEN 'saw_homepage'
        when saw_custom_lander = 1 then 'saw_custom_lander'
        else 'nope . . . check logic again'
	end as segment,
    count(distinct website_session_id) as sessions, -- remember the session_id is the id of users
	count(distinct case when products_made_it=1 then website_session_id else null end) as to_products,   
    -- these CASE WHEN gives us flags of 0 or 1.
	count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as to_mrfuzzy,
	count(distinct case when cart_made_it=1 then website_session_id else null end) as to_cart,
	count(distinct case when shipping_made_it=1 then website_session_id else null end) as to_shipping,
	count(distinct case when billing_made_it=1 then website_session_id else null end) as to_billing,
	count(distinct case when thankyou_made_it=1 then website_session_id else null end) as to_thankyou
from session_level_made_it_flagged
group by 1;

# Executed
# segment				sessions	to_products	to_mrfuzzy	to_cart	to_shipping	to_billing	to_thankyou
# saw_custom_lander			2316		1083		772			348		231			197			94
# saw_homepage				2261		942			684			296		200			168			72



-- FINAL  CLICK RATES
select 
case 
		when saw_homepage = 1 THEN 'saw_homepage'
        when saw_custom_lander = 1 then 'saw_custom_lander'
        else 'nope . . . check logic again'
end as segment,
-- count(distinct website_session_id) as sessions, -- remember the session_id is the id of users
count(distinct case when products_made_it=1 then website_session_id else null end)/
count(distinct website_session_id) as lander_click_rt,    -- these CASE WHEN gives us flags of 0 or 1.
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end)/
count(distinct case when products_made_it=1 then website_session_id else null end) as products_click_rt, 
count(distinct case when cart_made_it=1 then website_session_id else null end)/
count(distinct case when mrfuzzy_made_it=1 then website_session_id else null end) as mrfuzzy_click_rt,
count(distinct case when shipping_made_it=1 then website_session_id else null end)/
count(distinct case when cart_made_it=1 then website_session_id else null end) as cart_click_rt,
count(distinct case when billing_made_it=1 then website_session_id else null end)/
count(distinct case when shipping_made_it=1 then website_session_id else null end) as shipping_click_rt,
count(distinct case when thankyou_made_it=1 then website_session_id else null end)/
count(distinct case when billing_made_it=1 then website_session_id else null end) as billing_click_rt
from session_level_made_it_flagged
group by 1;


# Executed
# segment			lander_click_rt	 products_click_rt	mrfuzzy_click_rt	cart_click_rt	shipping_click_rt	billing_click_rt
# saw_custom_lander		0.4676			0.7128			0.4508				0.6638			0.8528				0.4772
# saw_homepage			0.4166	    	0.7261			0.4327				0.6757			0.8400				0.4286



/*
8. Please quantify the impact of our billing test, as well. Please analyze the lift generated from the test
(Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions
for the past month to understand monthly impact.
*/
-- ------------------------------- STEPS TO FOLLOW ----------------------------------------------------------------
-- STEP 1: Select all pageviews for relevant sessions
-- STEP 2: Identify each relevant pageview as the specific funnel step
-- STEP 3: Create the session-level conversion funnel view
-- STEP 4: Aggregate the data to assess funnel performance

select
billing_version_seen,
count(distinct website_session_id) as sessions,
sum(price_usd)/count(distinct website_session_id) as revenue_per_billing_page_seen
from (
select 
	website_pageviews.website_session_id,
	website_pageviews.pageview_url as billing_version_seen,  -- that is old billing page is /billing and new billing page /billing-2
	orders.order_id,
    orders.price_usd
from website_pageviews
	left join orders
		on orders.website_session_id = website_pageviews.website_session_id
		where website_pageviews.created_at >'2012-09-10' -- gotten from the assignment
		and website_pageviews.created_at < '2012-11-10'  -- gotten from the assignment
		and website_pageviews.pageview_url IN ('/billing','/billing-2')
) as billing_sessions_w_orders
group by 1;



# Executed
# billing_version_seen	sessions	revenue_per_billing_page_seen
# /billing				657				22.826484
# /billing-2			654				31.339297


-- New billing page ( "/billing-2" ) produces $31.34 per billing page seen
-- Old billing page ( "/billing" ) produces   $22.83 per billing page seen
-- So the difference or the lift is $8.51 per billing page view

####### Next look at how many sessions we had when someone hits the billing page

select
	count(website_session_id) as billing_sessions_past_month
from website_pageviews
where
	website_pageviews.pageview_url IN ('/billing','/billing-2')
    and created_at between '2012-10-27' and '2012-11-27' -- these are the past months
    
# Executed
-- We have 1,193 sessions from the past month on the billing page
-- Recall, the lift is $8.51 per billiing sessions.
-- 1,193 x $8.51 = $10,152.43
-- The value of the billing test over the past month is $10,152.43.
