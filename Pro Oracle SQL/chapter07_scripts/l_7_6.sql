select deptno, count(*)
from scott.emp
group by deptno
/

@showplan_last
