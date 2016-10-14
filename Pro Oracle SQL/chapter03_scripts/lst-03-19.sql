/* Listing 3-19 */

set autotrace traceonly explain

select /*+ ordered  */ empno, ename, dname, loc
from scott.dept, scott.emp
where emp.deptno = dept.deptno;


