/* Listing 5-6 */

select /* opt9 */ empno, ename 
from emp
where :empno is null
union all
select empno, ename 
from emp
where :empno = empno;

@pln opt9

