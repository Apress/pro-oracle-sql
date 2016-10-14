select /*+ gather_plan_statistics */
distinct dname, decode(
	d.deptno,
	10, (select count(*) from scott.emp where deptno= 10),
	20, (select count(*) from scott.emp where deptno= 20),
	30, (select count(*) from scott.emp where deptno= 30),
	(select count(*) from scott.emp where deptno not in (10,20,30))
) dept_count
from (select distinct deptno from scott.emp) d
join scott.dept d2 on d2.deptno = d.deptno
/

--@showplan_last
