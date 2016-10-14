
et linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a25
col root format a15
col level format 9999
col path format a30

spool l_10_23.txt


update hr.employees set manager_id = 171 where employee_id = 100

l

/


select lpad(' ',2*(level-1)) || last_name last_name
	,first_name, employee_id, level
	, connect_by_iscycle
from hr.employees
start with employee_id = 100
connect by nocycle prior employee_id = manager_id

l

/

select last_name, first_name, employee_id, manager_id
from hr.employees
where employee_id = 171

l

/

select last_name, first_name, employee_id, manager_id
from hr.employees
where manager_id = 171

l

/

rollback

l

/

--@showplan_last

spool off


