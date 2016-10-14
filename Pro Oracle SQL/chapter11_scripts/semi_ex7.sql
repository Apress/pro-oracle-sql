set echo on
-- semi_ex7.sql - restrictions

select /* in with or */ department_name 
   from hr.departments
   where 1=2
   or department_id in (select department_id from hr.employees);

select /* exists with or */ department_name 
   from hr.departments dept
   where 1=2 or exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* in with and */ department_name 
   from hr.departments
   where 1=1
   and department_id in (select department_id from hr.employees);

select /* exists with and */ department_name 
   from hr.departments dept
   where 1=1 and exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
