/* Listing 3-15 */


create index emp_jobfname_ix on employees(job_id, first_name, salary);

set autotrace traceonly

select * from employees where first_name = 'William';

select /*+ full(employees) */ * from employees where first_name = 'William';

select count(distinct job_id) ct from employees ;

