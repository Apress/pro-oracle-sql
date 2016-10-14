
select d.dname, count(empno) empcount
from scott.dept d
left outer join scott.emp e on d.deptno = e.deptno
group by d.dname
order by d.dname

l

/

--@showplan_last

