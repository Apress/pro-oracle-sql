/* Listing 4-7 */


select * from scott.emp ;

select * from scott.emp where deptno in (10, 20, 30) ;

select * from scott.emp where deptno not in (10, 20, 30) ;

select * from scott.emp where deptno not in (10, 20, 30)
or deptno is null;


