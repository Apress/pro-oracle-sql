/* Listing 4-1 */

set autotrace on

select distinct employee_id
from job_history j1
where not exists
(select null
from job_history j2
where j2.employee_id = j1.employee_id
and round(months_between(j2.start_date,j2.end_date)/12,0) <>
round(months_between(j1.start_date,j1.end_date)/12,0) );

select employee_id
from job_history
group by employee_id
having min(round(months_between(start_date,end_date)/12,0)) =
max(round(months_between(start_date,end_date)/12,0));


