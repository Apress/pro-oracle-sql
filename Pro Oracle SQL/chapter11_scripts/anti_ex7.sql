set echo on
-- semi_ex7.sql - restrictions

select /* not in with or */ department_name 
   from hr.departments
   where 1=2
   or department_id not in (select department_id from hr.employees);

select /* not exists with or */ department_name 
   from hr.departments dept
   where 1=2 or not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* in with and */ department_name 
   from hr.departments
   where 1=1
   and department_id not in (select department_id from hr.employees);

select /* exists with and */ department_name 
   from hr.departments dept
   where 1=1 and not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
