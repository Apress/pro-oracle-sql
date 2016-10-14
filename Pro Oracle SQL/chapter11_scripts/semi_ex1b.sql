set echo on
-- semi_ex1b.sql

select /* using exists */ department_name 
   from hr.departments dept
   where exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
