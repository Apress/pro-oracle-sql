/* Listing 6-11 */


select /* KM-EMPTEST1 */
empno, ename
from emp
where job = 'MANAGER' ;


select sql_id, child_number, sql_text
from v$sql
where sql_text like '%KM-EMPTEST1%';


select * from table(dbms_xplan.display_cursor('<sql_id goes here>',0,'ALLSTATS LAST'));

