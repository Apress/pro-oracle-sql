set echo on
-- anti_ex4.sql

select /* EXISTS */ department_name 
   from hr.departments dept
   where not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* EXISTS with hint */ department_name 
   from hr.departments dept
   where not exists (select /*+ hash_aj */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* IN */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

alter session set "_always_anti_join"=off;

select /* IN with AAJ=OFF*/ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

alter session set "_always_anti_join"=choose;

set echo off
