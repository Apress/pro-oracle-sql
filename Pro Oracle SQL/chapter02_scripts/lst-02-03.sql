/* Listing 2-3 */


alter system set events 'immediate trace name flush_cache';

alter system flush shared_pool;

set autotrace traceonly statistics

select * from hr.employees where department_id = 60;

set autotrace off

alter system set events 'immediate trace name flush_cache';

set autotrace traceonly statistics

select * from hr.employees where department_id = 60;

select * from hr.employees where department_id = 60;

set autotrace off

