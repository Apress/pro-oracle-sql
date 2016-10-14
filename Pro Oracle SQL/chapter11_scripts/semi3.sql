select distinct ename from scott.emp, scott.dept
where emp.deptno = dept.deptno
and loc > 'E%'
/

select ename from scott.emp, scott.dept
where emp.deptno = dept.deptno
and loc > 'E%'
/
