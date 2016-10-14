/* Listing 6-14 */


select /* KM1 */ job_id, department_id, last_name
from employees
where job_id = 'SA_REP'
and department_id is null ;


@pln KM1

create index emp_job_dept_ix on employees (department_id, job_id) compute statistics ;


select /* KM2 */ job_id, department_id, last_name
from employees
where job_id = 'SA_REP'
and department_id is null ;

@pln KM2

select /* KM3 */ last_name, phone_number
from employees
where phone_number = '650.507.9822';

@pln KM3

column column_name format a22 heading 'Column Name'
column index_name heading 'Index Name'
column column_position format 999999999 heading 'Pos#'
column descend format a5 heading 'Order'
column column_expression format a40 heading 'Expression'

break on index_name skip 1

select lower(b.index_name) index_name, b.column_position,
b.descend, lower(b.column_name) column_name
from all_ind_columns b
where b.table_owner = 'HR'
and b.table_name = 'EMPLOYEES'
order by b.index_name, b.column_position, b.column_name
/

create index emp_phone_ix on employees (phone_number) compute statistics ;

select /* KM4 */ last_name, phone_number
from employees
where phone_number = '650.507.9822';


@pln KM4






