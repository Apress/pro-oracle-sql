/* Listing 5-1 */

select employee_id, count(*) job_ct
from job_history
group by employee_id
having count(*) > 1;

