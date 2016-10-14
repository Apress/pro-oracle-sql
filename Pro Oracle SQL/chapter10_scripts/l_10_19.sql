
set linesize 200
set serveroutput off
set timing on

col last_name format a25
col first_name format a20

spool l_10_19.txt


with emp_recurse(employee_id,manager_id,last_name,lvl,path) as (
	select e.employee_id, null, e.last_name
		, 1 as lvl
		,e.last_name as path
	from hr.employees e
	where e.manager_id is null
	union all
	select e1.employee_id, e1.manager_id, e1.last_name
		,e2.lvl + 1 as lvl
		,e2.path || ',' || e1.last_name as path
	from hr.employees e1 
	join emp_recurse e2 on e2.employee_id= e1.manager_id
)
search depth first by last_name set last_name_order
select lpad(' ', r.lvl*2-1,' ') || r.last_name last_name, r.path
from emp_recurse r
order by last_name_order

l

/

@showplan_last

spool off

