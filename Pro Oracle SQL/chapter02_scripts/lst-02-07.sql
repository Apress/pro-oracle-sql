/* Listing 2-7 */

set autotrace traceonly explain

select employee_id, last_name, salary, department_id
from hr.employees
where department_id in
(select /*+ NO_UNNEST */department_id
from hr.departments where location_id > 1700);
