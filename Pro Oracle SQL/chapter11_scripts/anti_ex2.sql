set echo on
-- anti_ex2.sql

select /* IN */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

select /* EXISTS */ department_name 
   from hr.departments dept
   where not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* IN with NVL */ department_name 
   from hr.departments dept
   where department_id not in (select nvl(department_id,-10) from hr.employees emp);

select /* IN with NOT NULL */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp where department_id is not null);

set echo off
