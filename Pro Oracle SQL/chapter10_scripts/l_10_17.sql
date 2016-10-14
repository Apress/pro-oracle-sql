
set linesize 200
set serveroutput off
set timing on

col last_name format a25
col first_name format a20

spool l_10_17.txt

select lpad(' ',2*(level-1)) || e.last_name last_name
	, sys_connect_by_path(last_name,':') path
from hr.employees e
start with e.manager_id is null
connect by prior e.employee_id = e.manager_id
order siblings by e.last_name

l

/

@showplan_last

spool off
