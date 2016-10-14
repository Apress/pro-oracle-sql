/* Listing 3-12 */

set autotrace traceonly explain

select * from hr.employees
where department_id in (90, 100)
order by department_id desc;
