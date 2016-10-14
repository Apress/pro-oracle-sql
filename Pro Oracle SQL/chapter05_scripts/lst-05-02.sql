/* Listing 5-2 */


select employee_id, count(*) job_ct
from
(
select e.employee_id, e.job_id
from employees e
union all
select j.employee_id, j.job_id
from job_history j
)
group by employee_id
having count(*) > 1;
