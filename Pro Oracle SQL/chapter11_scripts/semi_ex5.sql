set echo on
-- semi_ex5.sql - no_semijoin hint

select /* in no_semijoin */ department_name 
   from hr.departments dept
   where department_id in (select /*+ no_semijoin */ department_id from hr.employees emp);

select /* exists no_semijoin */ department_name 
   from hr.departments dept
   where exists (select /*+ no_semijoin */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);
set echo off
