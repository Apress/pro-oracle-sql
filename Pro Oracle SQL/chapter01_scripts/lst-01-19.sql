/* Listing 1-19 */

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

delete from employees2
where department_id = 90;

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

rollback;

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

delete from (select * from employees2 where department_id = 90);

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

rollback;

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

delete from employees2
where department_id in (select department_id
from hr.departments
where department_name = 'Executive');

select employee_id, department_id, last_name, salary
from employees2
where department_id = 90;

rollback;

