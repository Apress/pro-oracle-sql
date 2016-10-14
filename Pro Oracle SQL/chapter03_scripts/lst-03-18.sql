/* Listing 3-18 */

set autotrace traceonly statistics

select empno, ename, dname, loc
from scott.emp, scott.dept
where emp.deptno = dept.deptno;

select /*+ ordered use_nl (dept emp) */ empno, ename, dname, loc
from scott.dept, scott.emp
where emp.deptno = dept.deptno;


