
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a25
col root format a15
col level format 9999
col path format a30

spool l_10_24.txt

update hr.employees set manager_id = 171 where employee_id = 100

l

/

with emp(employee_id,manager_id,last_name,first_name,lvl) as (
	select e.employee_id
		, null as manager_id
		, e.last_name
		, e.first_name
		, 1 as lvl 
	from hr.employees  e
	where e.employee_id =100
	union all
	select e.employee_id
		, e.manager_id
		, e.last_name
		, e.first_name
		, emp.lvl + 1 as lvl
	from hr.employees e
	join emp on emp.employee_id = e.manager_id
)
search depth first by last_name set order1
CYCLE employee_id SET is_cycle TO '1' DEFAULT '0'
select lpad(' ',2*(lvl-1)) || last_name last_name
	, first_name
	, employee_id
	, lvl
	, is_cycle
from emp
order by order1

l

/

select last_name, first_name, employee_id, manager_id
from hr.employees
where employee_id = 100

l

/

rollback

l

/

--@showplan_last

spool off


