
with lobtest as (
   select to_clob(d.dname ) dname
   from scott.emp e
   join scott.dept d on d.deptno = e.deptno
)
select l.dname
from lobtest l
group by l.dname

l

/


select d.dname, count(empno) empcount
from scott.emp e
join scott.dept d on d.deptno = e.deptno
group by (select dname from scott.dept d2 where d2.dname = d.dname)
order by d.dname

l

/


