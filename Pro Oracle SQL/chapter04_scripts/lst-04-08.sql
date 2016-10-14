/* Listing 4-8 */


select * from scott.emp where deptno is null ;

select * from scott.emp where deptno = null ;

select sal, comm, sal + comm as tot_comp
from scott.emp where deptno = 30;


