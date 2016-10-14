
set autotrace on statistics

with emps as (
	select last_name, first_name from hr.employees
) ,
mycube as (
  select last_name, first_name from emps
  union all
  select last_name, null first_name from emps
  union all
  select null last_name, first_name from emps
  union all
  select null last_name, null first_name from emps
)
select /*+ gather_plan_statistics */ *
from mycube
group by last_name, first_name

l

/

@showplan_last
