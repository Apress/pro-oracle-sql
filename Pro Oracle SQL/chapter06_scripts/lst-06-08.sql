/* Listing 6-8 */


select /*+ gather_plan_statistics */ empno, ename from scott.emp where ename = 'KING' ;

set serveroutput off

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));


