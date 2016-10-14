/* Listing 3-14 */

set autotrace traceonly explain

select min(department_id) from hr.employees ;

select min(department_id), max(department_id) from hr.employees ;

select (select min(department_id) from hr.employees) min_id,
	   (select max(department_id) from hr.employees) max_id
from dual;



