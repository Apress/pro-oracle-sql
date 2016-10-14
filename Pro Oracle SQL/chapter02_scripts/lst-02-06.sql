/* Listing 2-6 */

set autotrace traceonly explain

select * from hr.employees where department_id in (select department_id from hr.departments);

