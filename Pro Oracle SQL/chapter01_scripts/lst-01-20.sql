/* Listing 1-20 */

create table dept60_bonuses
(employee_id number
,bonus_amt number);

insert into dept60_bonuses values (103, 0);

insert into dept60_bonuses values (104, 100);

insert into dept60_bonuses values (105, 0);

commit;

select employee_id, last_name, salary
from hr.employees
where department_id = 60 ;

select * from dept60_bonuses;

merge into dept60_bonuses b
using (
select employee_id, salary, department_id
from hr.employees
where department_id = 60) e
on (b.employee_id = e.employee_id)
when matched then
update set b.bonus_amt = e.salary * 0.2
where b.bonus_amt = 0
delete where (e.salary > 7500)
when not matched then
insert (b.employee_id, b.bonus_amt)
values (e.employee_id, e.salary * 0.1)
where (e.salary < 7500);

select * from dept60_bonuses;

rollback ;

