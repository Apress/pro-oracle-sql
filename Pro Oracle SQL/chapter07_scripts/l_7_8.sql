
select /*+ gather_plan_statistics */
	d.dname
	, count(empno) empcount
from scott.emp e 
join scott.dept d on d.deptno = e.deptno
group by d.dname
order by d.dname

l

/

@showplan_last

