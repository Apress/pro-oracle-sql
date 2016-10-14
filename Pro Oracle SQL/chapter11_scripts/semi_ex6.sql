set echo on
-- semi_ex6.sql

select /* exists no_sj */ department_name 
   from hr.departments dept
   where exists (select /*+ no_semijoin */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* exists hash_sj */ department_name 
   from hr.departments dept
   where exists (select /*+ hash_sj */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* exists merge_sj */ department_name 
   from hr.departments dept
   where exists (select /*+ merge_sj */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* exists nl_sj */ department_name 
   from hr.departments dept
   where exists (select /*+ nl_sj */ null from hr.employees emp 
                    where emp.department_id = dept.department_id);

set echo off
