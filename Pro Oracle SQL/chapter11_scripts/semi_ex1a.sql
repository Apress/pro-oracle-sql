set echo on
-- semi_ex1a.sql

select /* using in */ department_name 
   from hr.departments dept
   where department_id in (select department_id from hr.employees emp);

set echo off
