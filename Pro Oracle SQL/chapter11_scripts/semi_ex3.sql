-- semi_ex3.sql - SEMI and DISTINCT not the same

select /* SEMI using IN */ department_id
from hr.employees
where department_id in (select department_id from hr.departments);

select /* inner join with distinct */ distinct emp.department_id 
from hr.departments dept, hr.employees emp
where dept.department_id = emp.department_id;

