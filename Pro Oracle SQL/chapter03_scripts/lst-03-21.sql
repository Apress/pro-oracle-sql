/* Listing 3-21 */

select distinct deptno,
ora_hash(deptno,1000) hv
from scott.emp
order by deptno;

select deptno
from
(
select distinct deptno,
ora_hash(deptno,1000) hv
from scott.emp
order by deptno
)
where hv between 100 and 500;

select distinct deptno,
ora_hash(deptno,1000,50) hv
from scott.emp
order by deptno;


select deptno
from
(
select distinct deptno,
ora_hash(deptno,1000,50) hv
from scott.emp
order by deptno
)
where hv between 100 and 500;

