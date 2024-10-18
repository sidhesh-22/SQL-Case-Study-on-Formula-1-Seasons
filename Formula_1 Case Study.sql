							-- SQL Case study to analyse the Formula 1 seasons --
				

-- Country which has produced the most F1 drivers.
	select nationality,count(*) 
	from drivers group by nationality order by 2 desc limit 1;


-- Country which has produced the most no of F1 circuits.
	select country,count(*) 
	from circuits group by country order by 2 desc limit 1;


-- Countries with exactly 5 constructors
	select nationality,count(*) 
	from constructors group by nationality having count(*) = 5;


-- Number of races this each year
	select year, count(*) 
	from races
	group by year
	order by year desc;


-- How many drivers participated in 2022 season?
	select count(distinct driverid) as no_of_drivers_in_2022
	from driver_standings
	where raceid in (select raceid from races r where year=2022);
	

-- The youngest and oldest F1 driver
	select max(case when rn=1 then forename||' '||surname end) as oldest_driver
	, max(case when rn=cnt then forename||' '||surname end) as youngest_driver
	from (
		select *, row_number() over (order by dob ) as rn, count(*) over() as cnt
		from drivers) x
	where rn = 1 or rn = cnt


-- List down the no of races that have taken place each year and mention which was the first and the last race of each season.
	select distinct year
	,first_value(name) over(partition by year order by date) as first_race
	, last_value(name) over(partition by year order by date 
						   range between unbounded preceding and unbounded following) as last_race
	, count(*) over(partition by year) as no_of_races
	from races
	order by year desc


-- Which circuit has hosted the most no of races. Display the circuit name, no of races, city and country.
	with cte as
		(select c.name as circuit_name, count(1) no_of_races
		, rank() over(order by count(1) desc) as rnk
		from races r
		join circuits c on c.circuitid=r.circuitid
		group by c.name)
	select circuit_name, no_of_races, c.location as city, c.country 
	from circuits c
	join cte on cte.circuit_name=c.name
	where rnk=1;


-- A report displaying the following for 2022 season:
--	year, race_no, circuit name, driver name, driver race position, driver race points, flag to indicate if winner
--	, constructor name, constructor position, constructor points, , flag to indicate if constructor is winner
--	, race status of each driver, flag to indicate fastest lap for which driver, total no of pit stops by each driver

		select r.raceid, r.year, r.round as race_no, r.name as circuit_name, concat(d.forename,' ',d.surname) as driver_name
		, ds.position as driver_position, ds.points as driver_points, case when ds.position=1 then 'WINNER' end as winner_flag
		, c.name as constructor_name, cs.position as constructor_position, cs.points as constructor_points
		, case when cs.position=1 then 'WINNER' end as cons_winner_flag, sts.status
		, case when lp.driverid is not null then 'Faster Lap' end as fastest_lap_indi, pt.no_of_stops
		from races r
		join driver_standings ds on ds.raceid=r.raceid
		join drivers d on d.driverid = ds.driverid
		join constructor_standings cs on cs.raceid=r.raceid 
		join constructors c on c.constructorid=cs.constructorid
		join results res on res.raceid=r.raceid and res.driverid=ds.driverid and res.constructorid=cs.constructorid
		join status sts on sts.statusid=res.statusid
		left join (	select lp.raceid, lp.driverid
					from lap_times lp
					join (	select raceid, min(time) as fastest_lap
							from lap_times
							group by raceid) x on x.raceid=lp.raceid and x.fastest_lap=lp.time
				 ) lp on lp.driverid = ds.driverid and lp.raceid=r.raceid
		left join (	select raceid,driverid, count(1) as no_of_stops
					from pit_stops
					group by raceid,driverid) pt on pt.driverid = ds.driverid and pt.raceid=r.raceid
		where year=2022 --and r.raceid=1074
		order by year, race_no, driver_position;


-- A report displaying the names of all F1 champions and the no of times they have won it.
		with cte as 
				(select r.year, concat(d.forename,' ',d.surname) as driver_name
				, sum(res.points) as tot_points
				, rank() over(partition by r.year order by sum(res.points) desc) as rnk
				from races r
				join driver_standings ds on ds.raceid=r.raceid
				join drivers d on d.driverid=ds.driverid
				join results res on res.raceid=r.raceid and res.driverid=ds.driverid --and res.constructorid=cs.constructorid 
				--where r.year>=2000
				group by r.year,  res.driverid, concat(d.forename,' ',d.surname) ),
			cte_rnk as
				(select * from cte where rnk=1)
		select driver_name, count(1) as no_of_championships
		from cte_rnk
		group by driver_name
		order by 2 desc;


-- Who has won the most constructor championships
		with cte as
				(select r.year, c.name as constructor_name
				, sum(res.points) as tot_points
				, rank() over(partition by r.year order by sum(res.points) desc) as rnk
				from races r
				join constructor_standings cs on cs.raceid=r.raceid
				join constructors c on c.constructorid = cs.constructorid
				join constructor_results res on res.raceid=r.raceid and res.constructorid=cs.constructorid --and res.constructorid=cs.constructorid 
				--where r.year>=2022
				group by r.year,  res.constructorid, c.name),
			cte_rnk as
				(select * from cte where rnk=1)
		select constructor_name, count(1) as no_of_championships
		from cte_rnk
		group by constructor_name
		order by 2 desc;


-- How many races has India hosted?
	select c.name as circuit_name,c.country, count(1) no_of_races
	from races r
	join circuits c on c.circuitid=r.circuitid
	where c.country='India'
	group by c.name,c.country;


-- Identify the driver who won the championship or was a runner-up. Also display the team they belonged to. 
	with cte as 
			(select r.year, concat(d.forename,' ',d.surname) as driver_name, c.name as constructor_name
			, sum(res.points) as tot_points
			, rank() over(partition by r.year order by sum(res.points) desc) as rnk
			from races r
			join driver_standings ds on ds.raceid=r.raceid
			join drivers d on d.driverid=ds.driverid
			join results res on res.raceid=r.raceid and res.driverid=ds.driverid 
		    join constructors c on c.constructorid=res.constructorid 
			where r.year>=2020
			group by r.year,  res.driverid, concat(d.forename,' ',d.surname), c.name)
	select year, driver_name, case when rnk=1 then 'Winner' else 'Runner-up' end as flag 
	from cte 
	where rnk<=2;


-- A report displaying the top 10 drivers with most wins.
	select driver_name, race_wins
	from (
		select ds.driverid, concat(d.forename,' ',d.surname) as driver_name
		, count(1) as race_wins
		, rank() over(order by count(1) desc) as rnk
		from driver_standings ds
		join drivers d on ds.driverid=d.driverid
		where position=1
		group by ds.driverid, concat(d.forename,' ',d.surname)
		order by race_wins desc, driver_name) x
	where rnk <= 10;


-- A report displaying the top 3 constructors of all time.
	select constructor_name, race_wins
	from (
		select cs.constructorid, c.name as constructor_name
		, count(1) as race_wins
		, rank() over(order by count(1) desc) as rnk
		from constructor_standings cs
		join constructors c on c.constructorid=cs.constructorid
		where position = 1
		group by cs.constructorid, c.name
		order by race_wins desc) x
	where rnk <= 3;


-- Drivers who have won races with multiple teams.
	select driverid, driver_name, string_agg(constructor_name,', ')
	from (
		select distinct r.driverid
		, concat(d.forename,' ',d.surname) as driver_name
		, c.name as constructor_name
		from results r
		join drivers d on d.driverid=r.driverid
		join constructors c on c.constructorid=r.constructorid
		where r.position=1) x
	group by driverid, driver_name
	having count(1) > 1
	order by driverid, driver_name;


-- Drivers who have never won any race.
	select d.driverid
	, concat(d.forename,' ',d.surname) as driver_name
	, nationality
	from drivers d 
	where driverid not in (select distinct driverid
						  from driver_standings ds 
						  where position=1)
	order by driver_name;


-- Are there any constructors who never scored a point? if so mention their name and how many races they participated in?
	select cs.constructorid, c.name as constructor_name
	, sum(cs.points) as total_points
	, count(1) as no_of_races
	from constructor_results cs
	join constructors c on c.constructorid=cs.constructorid
	group by cs.constructorid, c.name
	having sum(cs.points) = 0
	order by no_of_races desc, constructor_name ;


-- A report of the drivers who have won more than 50 races.
	select concat(d.forename,' ',d.surname) as driver_name
	, count(1) as race_wins
	from driver_standings ds
	join drivers d on ds.driverid=d.driverid
	where position=1
	group by concat(d.forename,' ',d.surname)
	having count(1) > 50
	order by race_wins desc, driver_name;


-- A report displaying the podium finishers of each race in 2022 season
	select r.name as race
	, concat(d.forename,' ',d.surname) as driver_name
	, ds.position
	from driver_standings ds 
	join races r on r.raceid=ds.raceid
	join drivers d on d.driverid=ds.driverid
	where r.year = 2022
	and ds.position <= 3
	order by r.raceid;


-- For 2022 season, mention the points structure for each position. i.e. how many points are awarded to each race finished position. 
	with cte as 
		(select min(res.raceid) as raceid
		from races r
		join results res on res.raceid=r.raceid
		where year=2022)
	select r.position, r.points
	from results r
	join cte on cte.raceid=r.raceid
	where r.points > 0;


-- How many races has the top 5 constructors won in the last 10 years.
	*** Correction to Question: How many races has each of the top 5 constructors won in the last 10 years.
	with top_5_teams as
		(select constructorid, constructor_name
			from (
				select cs.constructorid, c.name as constructor_name
				, count(1) as race_wins
				, rank() over(order by count(1) desc) as rnk
				from constructor_standings cs
				join constructors c on c.constructorid=cs.constructorid
				where position = 1
				group by cs.constructorid, c.name
				order by race_wins desc) x
			where rnk <= 5)
	select cte.constructorid, cte.constructor_name, coalesce(cs.wins,0) as wins
	from top_5_teams cte 
	left join ( select cs.constructorid, count(1) as wins
				from constructor_standings cs 
				join races r on r.raceid=cs.raceid
				where cs.position = 1
				and r.year >= (extract(year from current_date) - 10)
			    group by cs.constructorid
			  ) cs 
		on cte.constructorid = cs.constructorid
	order by wins desc;


-- Winners of every sprint so far in F1
	select r.year, r.name, concat(d.forename,' ',d.surname) as driver_name
	from sprint_results sr
	join drivers d on d.driverid=sr.driverid
	join races r on r.raceid=sr.raceid
	where sr.position=1
	order by 1,2;


-- Driver who has the most no of 'Did Not Qualify' during the race.
	select driver_name, cnt
	from (
		select r.driverid
		, concat(d.forename,' ',d.surname) as driver_name
		, count(1) as cnt
		, rank() over(order by count(1) desc) as rnk
		from status s
		join results r on r.statusid=s.statusid
		join drivers d on d.driverid=r.driverid
		where s.status='Did not qualify'
		group by r.driverid, concat(d.forename,' ',d.surname)
		order by cnt desc) x
	where rnk=1;


-- Identify the drivers who did not finish the race and the reason for it, during the 2022 season
	select concat(d.forename,' ',d.surname) as driver_name
	, s.status
	from results r
	join status s on s.statusid=r.statusid
	join drivers d on d.driverid=r.driverid
	where r.raceid = (select max(raceid) from races where year=2022)
	and r.statusid<>1;


-- Driver with the most lap time in F1 history?
	select driver_name, total_lap_time
	from (
		select lt.driverid
		, concat(d.forename,' ',d.surname) as driver_name
		, sum(time) as total_lap_time
		, rank() over(order by sum(time) desc) as rnk
		from lap_times lt
		join drivers d on d.driverid=lt.driverid
		group by lt.driverid, concat(d.forename,' ',d.surname)) x
	where rnk=1;


-- Top 3 race finishes
	select driver_name, no_of_podiums
	from (select ds.driverid, concat(d.forename,' ',d.surname) as driver_name
		, count(1) as no_of_podiums
		, rank() over(order by count(1) desc) as rnk
		from driver_standings ds 
		join drivers d on d.driverid=ds.driverid
		where ds.position <= 3
		group by ds.driverid, concat(d.forename,' ',d.surname)) x
	where rnk<=3;

