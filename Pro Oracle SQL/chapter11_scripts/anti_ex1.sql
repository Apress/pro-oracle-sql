set echo on
-- anti_ex1.sql

select /* IN */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

select /* EXISTS */ department_name 
   from hr.departments dept
   where not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
