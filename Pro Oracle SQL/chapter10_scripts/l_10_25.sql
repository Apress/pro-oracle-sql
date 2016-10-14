
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a25
col root format a15
col level format 9999
col path format a30

spool l_10_25.txt

select lpad(' ',2*(level-1)) || e.last_name last_name, connect_by_isleaf
from hr.employees e
start with e.manager_id is null
connect by prior e.employee_id = e.manager_id
order siblings by e.last_name

l

/

@showplan_last

spool off


