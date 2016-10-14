/* Listing 1-18 */


create table employees2 as select * from hr.employees ;

alter table employees2
 add constraint emp2_emp_id_pk primary key (employee_id) ;

select employee_id, last_name, salary
from hr.employees where department_id = 90 ;

update employees2
set salary = salary * 1.10 -- increase salary by 10%
where department_id = 90 ;

commit ;

select employee_id, last_name, salary
from employees2 where department_id = 90 ;

update hr.employees employees
set salary = (select employees2.salary
				from employees2
				where employees2.employee_id = employees.employee_id
				and employees.salary != employees2.salary)
				where department_id = 90 ;

select employee_id, last_name, salary
from hr.employees where department_id = 90 ;

rollback ;

update hr.employees 
set salary = salary * 1.10
where department_id in 
(select department_id
from departments
where department_name = 'Executive') ;

select employee_id, last_name, salary
from hr.employees
where department_id in 
(select department_id
from departments
where department_name = 'Executive') ;

rollback ;

update (select e1.salary, e2.salary new_sal
from hr.employees e1, employees2 e2
where e1.employee_id = e2.employee_id
and e1.department_id = 90)
set salary = new_sal;

select employee_id, last_name, salary, commission_pct
from hr.employees where department_id = 90 ;

rollback ;

update hr.employees employees
set (salary, commission_pct) = (select employees2.salary, .10 comm_pct
from employees2
where employees2.employee_id = employees.employee_id
and employees.salary != employees2.salary)
where department_id = 90 ;

select employee_id, last_name, salary, commission_pct
from hr.employees where department_id = 90 ;

rollback ;

