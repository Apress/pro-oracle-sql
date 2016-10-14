select ename from scott.emp
 where exists (select /*+ hash_sj */ deptno from scott.dept where loc > 'E%' and emp.deptno = dept.deptno)
/
select ename from scott.emp
 where exists (select /*+ merge_sj */ deptno from scott.dept where loc > 'E%' and emp.deptno = dept.deptno)
/
select ename from scott.emp
 where exists (select /*+ nl_sj */ deptno from scott.dept where loc > 'E%' and emp.deptno = dept.deptno)
/
