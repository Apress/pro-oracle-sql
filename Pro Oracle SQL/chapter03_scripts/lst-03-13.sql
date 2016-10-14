/* Listing 3-13 */

set autotrace traceonly explain

select email from hr.employees ;

select first_name, last_name from hr.employees
where first_name like 'A%' ;

select * from hr.employees order by employee_id ;

select * from hr.employees order by employee_id desc ;

