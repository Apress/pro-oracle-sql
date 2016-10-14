select d.dname, count(empno) empcount
from scott.emp e
join scott.dept d on d.deptno = e.deptno
order by d.dname

l

/

--@showplan_last
