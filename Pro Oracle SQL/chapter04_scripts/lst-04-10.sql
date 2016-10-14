/* Listing 4-10 */


select comm, count(*) ctr
from scott.emp
group by comm ;

select comm, count(*) ctr
from scott.emp
group by comm
order by comm ;

select comm, count(*) ctr
from scott.emp
group by comm
order by comm
nulls first ;

select ename, sal, comm
from scott.emp
order by comm, ename ;


