/* Listing 3-22 */

set autotrace traceonly explain

select empno, ename, dname, loc
from scott.dept, scott.emp;

