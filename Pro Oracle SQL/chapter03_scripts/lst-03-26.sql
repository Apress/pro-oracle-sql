/* Listing 3-26 */

select e1.ename, e1.deptno, e1.job,
e2.ename, e2.deptno, e2.job
from e1,
e2
where e1.empno (+) = e2.empno
union
select e1.ename, e1.deptno, e1.job,
e2.ename, e2.deptno, e2.job
from e1,
e2
where e1.empno = e2.empno (+);

set autotrace traceonly explain

/

