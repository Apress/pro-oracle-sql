
set autotrace on statistics

with emps as (
	select /*+ gather_plan_statistics */ 
		last_name
		, first_name
	from hr.employees
	group by cube(first_name,last_name)
)
select rownum
	, last_name
	, first_name
from emps

l

/

@showplan_last
