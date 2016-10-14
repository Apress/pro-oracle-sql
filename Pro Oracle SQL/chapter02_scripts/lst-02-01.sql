/* Listing 2-1 

connect to hr demo schema

*/


select * from employees where department_id = 60;

SELECT * FROM EMPLOYEES WHERE DEPARTMENT_ID = 60;

select /* a_comment */ * from employees where department_id = 60;

select sql_text, sql_id, child_number, hash_value, address, executions
from v$sql where upper(sql_text) like '%EMPLOYEES%';



