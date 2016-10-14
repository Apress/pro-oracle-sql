
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a15
col root format a15
col level format 9999
col path format a30

spool l_10_21.txt


update hr.employees set manager_id= null where last_name ='Kochhar'

l

/


with emp_recurse(employee_id,manager_id,last_name,lvl,path) as (
	select /*+ gather_plan_statistics */
		e.employee_id
		, null as manager_id
		, e.last_name
		, 1 as lvl
		, ':' || e.last_name || ':' as path
	from hr.employees  e
	where e.manager_id is null
	union all
	select
		e.employee_id
		, e.manager_id
		, e.last_name
		, er.lvl + 1 as lvl
		, er.path || e.last_name  || ':' as path
	from hr.employees e
	join emp_recurse er on er.employee_id = e.manager_id
	join hr.employees e2 on e2.employee_id = e.manager_id
)
search depth first by last_name set order1 ,
emps as (
	select lvl
		, last_name
		, path
		, substr(path,2,instr(path,':',2)-2) root
	from emp_recurse
)
select 
	lvl
	, lpad(' ',2*(lvl-1)) || last_name last_name
	, root
	, path
from emps
where root = 'Kochhar'

l

/

rollback;

@showplan_last

spool off


