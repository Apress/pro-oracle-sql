-- semi_ex2.sql - alternatives to EXISTS and IN

set echo on 
select /* inner join */ department_name 
from hr.departments dept, hr.employees emp
where dept.department_id = emp.department_id;

-- obviously not the same due to the number of rows returned
-- let’s try throwing in a DISTINCT

select /* inner join with distinct */ distinct department_name 
from hr.departments dept, hr.employees emp
where dept.department_id = emp.department_id;

-- that one looks promising
-- let’s try one more with an intersect

select /* ugly intersect */ department_name
from hr.departments dept, 
   (select department_id from hr.departments
    intersect
    select department_id from hr.employees) b
where b.department_id = dept.department_id;

-- finally there is the somewhat obscure ANY keyword

select /* inner join ANY */ department_name
from hr.departments dept
where department_id = ANY (select department_id from hr.employees emp);
set echo off

