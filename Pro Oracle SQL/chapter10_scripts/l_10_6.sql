
set timing on
set autotrace on statistics

set pagesize 60
set serveroutput off
set line 200
col cust_income_level format a20 head 'INCOME LEVEL'
col country_name format a30 head 'COUNTRY'
col country_cust_count format 999999 head 'CUSTOMER|COUNT'

clear breaks

spool l_10_6.txt

with cust as (
	select /*+ inline gather_plan_statistics */
	  b.cust_income_level,
	  a.country_name
	from sh.customers b
	join sh.countries a on a.country_id = b.country_id
),
median_income_set as (
	select /*+ inline */ cust_income_level, count(*) income_level_count
	from cust
	group by cust_income_level
	having count(cust_income_level) > (
		select median(income_level_count) income_level_count
		from (
			select cust_income_level, count(*) income_level_count
			from cust
			group by cust_income_level
		)
	)
)
select country_name, cust_income_level, count(country_name) country_cust_count
from cust c
having count(country_name) >
	(
	  select count(*) * .01
	  from cust c2
	)
	or cust_income_level in ( select mis.cust_income_level from median_income_set mis)
group by country_name, cust_income_level
order by 1,2

l

/

@showplan_last

spool off

