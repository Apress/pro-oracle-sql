
set echo on
-- anti_ex5.sql

set autotrace trace exp

select /* NOT IN */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp);

select /* NOT NULL */ department_name 
   from hr.departments dept
   where department_id not in (select department_id from hr.employees emp 
                               where department_id is not null);

select /* NVL */ department_name 
   from hr.departments dept
   where department_id not in (select nvl(department_id,'-10') 
                               from hr.employees emp);

set echo off
