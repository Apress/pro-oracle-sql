select ename from scott.emp
 where deptno in (select deptno from scott.dept where loc > 'E%')
/
