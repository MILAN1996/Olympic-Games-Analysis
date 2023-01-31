select * from ol

--all olympic games held so far
select distinct Games from ol; -- 51 games

--total no of nations participated in each game
select Games,count(distinct NOC) as nations_count
from ol
group by Games
order by count(distinct NOC); --

--nation participated in all the olympic games
	-- Since we know total games played is 51
select NOC,count(distinct Games) as nations
from ol
group by NOC
having count(distinct Games) = '51'
order by count(distinct Games); -- SUI, ITA,FRA,GBR played all 51 games

-- sports played in all summer games
     --cal total summer games played
select 
count(distinct Games)
from ol
where Season = 'Summer' -- 29 games
      -- games played by each sport
 select sport, count(distinct case when Games like '%Summer' then Games end) as number_of_summer_games
 from ol
 group by Sport
 having count(distinct case when Games like '%Summer' then Games end) = '29'
 order by 2 

 -- sports played only once 
select 
sport 
from
(
select sport,count(distinct Games) as games_played
from ol
group by Sport
) as games_played
where games_played = 1

-- total number of sports played in each game
select Games, count(distinct sport)
from ol
group by Games

--oldest athletes to win gold medal
select Names,
case when Medal = 'Gold' then Age end as aged_medalists
from ol
order by aged_medalists desc

-- top 5 athletes who won most gold medal
select Names, count(Medal) as gold_medals
from ol
where medal = 'Gold'
group by Names
order by 2 desc

-- top5 most successful countries
select r.region,count(case when medal !='null' then '1' end) as no_of_medals
from ol
join noc_regions r 
on r.NOC = ol.NOC
group by r.region
order by count(medal) desc

-- gold,silver,bronze medals won by each country
select r.region,
count(case when medal='gold' then medal end) as gold_medals,
count(case when medal='silver' then medal end) as bronze_medals,
count(case when medal='bronze' then medal end) as silver_medals
from ol
join noc_regions r 
on r.NOC = ol.NOC
group by r.region


-- List down total gold, silver and bronze medals won by each country corresponding to each olympic games
select r.region, games,
count(case when medal='gold' then medal end) as gold_medals,
count(case when medal='silver' then medal end) as bronze_medals,
count(case when medal='bronze' then medal end) as silver_medals
from ol
join noc_regions r 
on r.NOC = ol.NOC
group by r.region, games
order by Games 

-- Identify which country won the most gold, most silver and most bronze medals in each olympic games
	-- create temp table counting medals
select  games,r.region,
count(case when medal='gold' then medal end) as gold_medals,
count(case when medal='silver' then medal end) as bronze_medals,
count(case when medal='bronze' then medal end) as silver_medals
into #games_by_medals 
from ol
join noc_regions r 
on r.NOC = ol.NOC
group by  games,r.region
order by Games

	-- create max medals table
select games,
MAX(gold_medals) as max_gold,
MAX(silver_medals)as max_silver,
MAX(bronze_medals)as max_bronze
into #max_medals
from #games_by_medals 
group by Games 

-- select countries with max medals
select g.games,
max(case when gold_medals = max_gold then m.region + '-' + str(max_gold) end ) as max_gold,
max(case when silver_medals = max_silver then m.region + '-' + str(max_silver) end) as max_silver,
max(case when bronze_medals = max_bronze then m.region + '-' + str(max_bronze)end ) max_bronze
from #max_medals g
inner join #games_by_medals m on
g.Games = m.Games
group by g.games
order by g.Games

-- Which countries have never won gold medal but have won silver/bronze medals?
select r.region,
count(case when medal='gold' then medal end) as gold_medals,
count(case when medal='silver' then medal end) as bronze_medals,
count(case when medal='bronze' then medal end) as silver_medals
into #games_by_medal
from ol
join noc_regions r 
on r.NOC = ol.NOC
group by r.region

select region, bronze_medals,silver_medals
from #games_by_medal
where gold_medals = 0 
order by bronze_medals desc

-- in which sports india won highest medals
select sport,count(case when medal !='null' then '1' end) as no_of_medals
from ol
join noc_regions r 
on r.NOC = ol.NOC
where r.region = 'India'
group by Sport
order by 2 desc

-- medals in each games for india in hockey
select games,count(case when medal !='null' then '1' end) as no_of_medals
from ol
join noc_regions r 
on r.NOC = ol.NOC
where r.region = 'India' and Sport = 'hockey'
group by games
order by 2 desc