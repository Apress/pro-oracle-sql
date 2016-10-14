set echo on
-- anti_ex3.sql

select /* IN */ department_name 
   from hr.departments dept
   where department_id not in (select /*+ nl_aj */ department_id from hr.employees emp);

select /* EXISTS */ department_name 
   from hr.departments dept
   where not exists (select /*+ nl_aj */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

set echo off
