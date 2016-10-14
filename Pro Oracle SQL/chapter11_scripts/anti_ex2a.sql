set echo on
-- anti_ex2a.sql

select /* IN */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);
set echo off
