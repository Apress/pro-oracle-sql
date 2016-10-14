/* Listing 3-17 */

set autotrace traceonly explain

select empno, ename, dname, loc
from emp, dept
where emp.deptno = dept.deptno;

