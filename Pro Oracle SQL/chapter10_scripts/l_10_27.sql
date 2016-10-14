
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a25
col root format a15
col level format 9999
col path format a30

spool l_10_27.txt

with emp(manager_id,employee_id,last_name,lvl) as (
	select e.manager_id, e.employee_id, e.last_name, 1 as lvl
	from hr.employees e
	where e.manager_id is null
	union all
	select e.manager_id, nvl(e.employee_id,null) employee_id
		,  e.last_name, emp.lvl + 1 as lvl
	from hr.employees e
	join emp on emp.employee_id = e.manager_id
)
search depth first by last_name set last_name_order
select lpad(' ',2*(lvl-1)) || last_name last_name,
	lvl,
	lead(lvl) over (order by last_name_order) leadlvlorder,
	case
	when ( lvl - lead(lvl) over (order by last_name_order) ) < 0
	then 0
	else 1
	end isleaf
from emp

l

/

@showplan_last

spool off

