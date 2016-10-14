
set linesize 200
set serveroutput off
set timing on

select /*+ gather_plan_statistics */
	prod_name
	, channel_desc
	, (
		select avg(c2.unit_cost)
		from sh.costs c2
		where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
		and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') and to_date('12/31/2000')	
		) avg_cost
	, (
		select min(c2.unit_cost)
		from sh.costs c2
		where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
		and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') and to_date('12/31/2000')	
		) min_cost
	, (
		select max(c2.unit_cost)
		from sh.costs c2
		where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
		and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') and to_date('12/31/2000')	
		) max_cost
from (
	select distinct pr.prod_id, pr.prod_name, ch.channel_id, ch.channel_desc
	from sh.channels ch
		, sh.products pr
		, sh.costs co
	where ch.channel_id = co.channel_id
		and co.prod_id = pr.prod_id
		and co.time_id between to_date('01/01/2000','mm/dd/yyyy') and to_date('12/31/2000')
) c
order by prod_name, channel_desc
/

@showplan_last

