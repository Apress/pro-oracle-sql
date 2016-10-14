
select /*+ gather_plan_statistics */
  d.dname
  , trunc(e.hiredate,'YYYY') hiredate
  , count(empno) empcount
from scott.emp e
join scott.dept d on d.deptno = e.deptno
group by d.dname, trunc(e.hiredate,'YYYY')
having 
  count(empno) >= 5
  and trunc(e.hiredate,'YYYY') between
    (select trunc(add_months(min(hiredate),12),'YYYY') from scott.emp)
    and 
    (select max(hiredate) from scott.emp)
order by d.dname

l

/

@showplan_last

