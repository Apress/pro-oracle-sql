set echo on
-- semi_ex.sql

select /* using in */ department_name 
   from hr.departments
   where department_id in (select department_id from hr.employees);

select /* using exists */ department_name 
   from hr.departments dept
   where exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
