/* Listing 6-9 */


select ename from scott.emp where ename = 'KING' ;

select * from table(dbms_xplan.display_cursor(null,null,'ALLSTATS LAST'));

