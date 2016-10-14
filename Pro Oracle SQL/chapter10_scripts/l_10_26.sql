
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a25
col root format a15
col level format 9999
col path format a30

spool l_10_26.txt

with leaves as (
	select employee_id
	from hr.employees
	where employee_id not in (
		select manager_id
		from hr.employees
		where manager_id is not null
	)
),
emp(manager_id,employee_id,last_name,lvl,isleaf) as (
	select e.manager_id, e.employee_id, e.last_name, 1 as lvl, 0 as isleaf
	from hr.employees e
	where e.manager_id is null
	union all
	select e.manager_id, nvl(e.employee_id,null) employee_id,  e.last_name, emp.lvl + 1 as lvl
		, decode(l.employee_id,null,0,1) isleaf
	from hr.employees e
	join emp on emp.employee_id = e.manager_id
	left outer join leaves l on l.employee_id = e.employee_id
)
search depth first by last_name set order1
select lpad(' ',2*(lvl-1)) || last_name last_name, isleaf
from emp

l

/

@showplan_last

spool off

