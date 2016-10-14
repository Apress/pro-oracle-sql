/* Listing 3-25 */

create table e1 as select * from emp where deptno in (10,20);

create table e2 as select * from emp where deptno in (20,30);


select e1.ename, e1.deptno, e1.job, e2.ename, e2.deptno, e2.job
from e1
full outer join
e2
on (e1.empno = e2.empno);

set autotrace traceonly explain

/

