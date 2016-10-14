set echo on
-- semi_ex4.sql – EXISTS with non-correlated subquery mistake

select /* correlated */ department_id 
   from hr.departments dept
   where exists (select department_id from hr.employees emp 
                    where emp.department_id = dept.department_id);

select /* not correlated */ department_id 
   from hr.departments dept
   where exists (select department_id from hr.employees emp );

select /* not correlated no nulls */ department_id 
   from hr.departments dept
   where exists (select department_id from hr.employees emp where department_id is not null);

select /* not correlated totally unrelated */ department_id 
   from hr.departments dept
   where exists (select 'anything' from dual);

select /* not correlated empty subquery */ department_id 
   from hr.departments dept
   where exists (select 'anything' from dual where 1=2);
set echo off

