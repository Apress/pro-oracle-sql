
set linesize 200
set serveroutput off
set timing on

col first_name format a12
col last_name format a12
col root format a12
col level format 9999
col path format a30

spool l_10_20.txt

update hr.employees set manager_id= null where last_name ='Kochhar'

l

/
 
select /*+ inline gather_plan_statistics */ 
	level
	, lpad(' ',2*(level-1)) || last_name last_name
	, first_name
	, CONNECT_BY_ROOT last_name as root
	, sys_connect_by_path(last_name,':') path
from hr.employees
where connect_by_root last_name = 'Kochhar'
connect by prior employee_id = manager_id
start with manager_id is null

l

/

rollback;

@showplan_last

spool off
