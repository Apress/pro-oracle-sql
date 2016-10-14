/* Listing 6-13 */



explain plan for
select * from emp e, dept d
where e.deptno = d.deptno
and e.ename = 'JONES' ;


select * from table(dbms_xplan.display(format=>'ALL'));

select empno, ename from emp e, dept d
where e.deptno = d.deptno
and e.ename = 'JONES' ;


select * from table(dbms_xplan.display_cursor(null,null,format=>'ALLSTATS LAST -COST -BYTES'));

variable v_empno number

exec :v_empno := 7566 ;

select * from emp where empno = :v_empno ;

select * from table(dbms_xplan.display_cursor(null,null,format=>'+PEEKED_BINDS'));

select /*+ parallel(d, 4) parallel (e, 4) */
d.dname, avg(e.sal), max(e.sal)
from dept d, emp e
where d.deptno = e.deptno
group by d.dname
order by max(e.sal), avg(e.sal) desc;

select * from table(dbms_xplan.display_cursor(null,null,'TYPICAL -BYTES -COST'));


