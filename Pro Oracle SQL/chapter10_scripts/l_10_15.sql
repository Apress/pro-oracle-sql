
set linesize 200
set serveroutput off
set timing on

col last_name format a25
col first_name format a20

spool l_10_15.txt

select lpad(' ', level*2-1,' ') || e.last_name last_name, level
from hr.employees e
connect by prior e.employee_id = e.manager_id
start with e.manager_id is null
order siblings by e.last_name

l

/

@showplan_last

spool off
