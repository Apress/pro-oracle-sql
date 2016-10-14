/* Listing 3-20 */

set autotrace traceonly explain

select /*+ use_hash (dept, emp)  */ empno, ename, dname, loc
from scott.dept, scott.emp
where emp.deptno = dept.deptno;


