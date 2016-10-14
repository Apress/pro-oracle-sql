/* Listing 2-8 */

set autotrace traceonly explain

select outer.employee_id, outer.last_name, outer.salary, outer.department_id
from hr.employees outer
where outer.salary >
(select avg(inner.salary)
from hr.employees inner
where inner.department_id = outer.department_id)
;
