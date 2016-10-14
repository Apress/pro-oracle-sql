
set linesize 200
set serveroutput off
set timing on

col last_name format a25
col first_name format a20

spool l_10_13.txt

with emp as (
	select /*+ inline gather_plan_statistics */ 
		e.last_name, e.first_name, e.employee_id, e.manager_id, d.department_name
	from hr.employees e
	left outer join hr.departments d on d.department_id = e.department_id
), 
emp_recurse (last_name,first_name,employee_id,manager_id,department_name,lvl) as (
	select e.last_name, e.first_name
		, e.employee_id, e.manager_id
		, e.department_name, 1 as lvl 
	from emp e where e.manager_id is null
	union all
	select emp.last_name, emp.first_name
	, emp.employee_id, emp.manager_id
	,emp.department_name, empr.lvl + 1 as lvl
	from emp
	join emp_recurse empr on empr.employee_id = emp.manager_id 
)
	search depth first by last_name set order1
select lpad(' ', lvl*2-1,' ') || er.last_name last_name
	, er.first_name
	, er.department_name
from emp_recurse er

l

/

@showplan_last

spool off

