/* Listing 5-5 */

variable empno number
variable getall number

exec :empno := 7369;

exec :getall := 1;

select /* opt1 */ empno, ename 
from emp
where empno = CASE WHEN :GetAll <> 1 THEN :empno ELSE empno END;

@pln opt1

select /* opt2 */ empno, ename 
from emp
where (:GetAll = 1) OR (empno = :empno);

@pln opt2

exec :getall := 0;

select /* opt3 */ empno, ename 
from emp
where empno = CASE WHEN :GetAll <> 1 THEN :empno ELSE empno END;

@pln opt3

select /* opt4 */ empno, ename 
from emp
where (:GetAll = 1) OR (empno = :empno);

@pln opt4

select /* opt5 */ empno, ename 
from emp
where empno = NVL(:empno, empno);

@pln opt5

select /* opt6 */ empno, ename 
from emp
where (:empno is null) OR (:empno = empno);

@pln opt6

exec :empno := null;

select /* opt7 */ empno, ename 
from emp
where empno = NVL(:empno, empno);

@pln opt7

select /* opt8 */ empno, ename 
from emp
where (:empno is null) OR (:empno = empno);

@pln opt8


