
set linesize 200
set serveroutput off
set timing on

col last_name format a25
col first_name format a20

spool l_10_12.txt

with emp as (
	select /*+ inline gather_plan_statistics */
		e.last_name, e.first_name
		, e.employee_id, d.department_id
		, e.manager_id, d.department_name
	from hr.employees e
	left outer join hr.departments d on d.department_id = e.department_id
)
select lpad(' ', level*2-1,' ') || emp.last_name last_name
	, emp.first_name
	, department_name
from emp
connect by prior emp.employee_id = emp.manager_id
start with emp.manager_id is null
order siblings by emp.last_name

l

/

@showplan_last

spool off
