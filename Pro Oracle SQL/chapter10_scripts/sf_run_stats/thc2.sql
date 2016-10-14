
set feed off term off echo off

-- removed by parent shell
host touch ./child_&1..lock

declare
	v_test dual.dummy%type;
begin

	DBMS_APPLICATION_INFO.SET_MODULE( module_name => 'RUN_2', action_name => null);

	lock table semaphore in share mode;

	for x in 1..20
	loop

declare
	i number;
begin
select count(*) into i
from (
with cust as (
	select /*+ inline gather_plan_statistics */
	  b.cust_income_level,
	  a.country_name
	from sh.customers b
	join sh.countries a on a.country_id = b.country_id
)
select country_name, cust_income_level, count(country_name) country_cust_count
from cust c
having count(country_name) >
	(
	  select count(*) * .01
	  from cust c2
	)
	or count(cust_income_level) >=
	(
	  select median(income_level_count)
	  from (
	    select cust_income_level, count(*) *.25 income_level_count
	    from cust
	    group by cust_income_level
	  )
	)
group by country_name, cust_income_level
order by 1,2
);
end;

	end loop;

	-- release lock
	commit;


	-- don't exit till master lock released
	lock table exit_semaphore in share mode;
	commit;

	DBMS_APPLICATION_INFO.SET_MODULE(null,null);

end;
/

exit;


