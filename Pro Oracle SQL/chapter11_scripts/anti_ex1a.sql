set echo on
/bin/bash: ./junk.sql: Permission denied
-- anti_ex1a.sql

select /* using in */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

set echo off
