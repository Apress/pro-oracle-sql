select ename from scott.emp
 where exists (select deptno from scott.dept where loc > 'E%' and emp.deptno = dept.deptno)
/
select ename from scott.emp
 where exists (select deptno from scott.dept where emp.deptno = dept.deptno)
/
