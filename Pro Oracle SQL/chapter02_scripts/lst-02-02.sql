/* Listing 2-2 */

variable v_dept number

exec :v_dept := 10

select * from hr.employees where department_id = :v_dept;

exec :v_dept := 20

select * from hr.employees where department_id = :v_dept;

exec :v_dept := 30

select * from hr.employees where department_id = :v_dept;

select sql_text, sql_id, child_number, hash_value, address, executions
from v$sql where sql_text like '%v_dept';

