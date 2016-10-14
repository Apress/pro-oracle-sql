/* Listing 1-16 */

insert into hr.jobs (job_id, job_title, min_salary, max_salary)
values ('IT_PM', 'Project Manager', 5000, 11000) ;


insert into scott.bonus (ename, job, sal)
select ename, job, sal * .10
from scott.emp;
