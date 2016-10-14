
set time off
set sqlprompt "SQL> "
set echo on

create type dept_location_type
as object
  ( 
    street_address     VARCHAR2(40)
    , postal_code        VARCHAR2(10)
    , city               VARCHAR2(30)
    , state_province     VARCHAR2(10)
    , country_id         CHAR(2)
    , order member function match (e dept_location_type) return integer
);
/

create or replace type body dept_location_type
as order member function match (e dept_location_type) return integer 
is
  begin
    if city < e.city then
      return -1;
    elsif city > e.city then
      return 1;
    else
      return 0;
    end if;
  end;
end;
/

create table deptobj
as
select d.deptno,d.dname
from scott.dept d
/

alter table deptobj add (dept_location dept_location_type)
/

set echo off

update deptobj 
set dept_location = 
  dept_location_type('1234 Money St', '97401','Eugene', 'OR', 'US')
where deptno=20

l

/

update deptobj 
set dept_location = 
  dept_location_type('459 Durella Street', '97463','Oakridge', 'OR', 'US')
where deptno=40

l

/

update deptobj 
set dept_location = 
  dept_location_type('12642 Rex Rd', '97006','Beavertown', 'OR', 'US')
where deptno=10

l

/

update deptobj 
set dept_location = 
  dept_location_type('9298 Hamilton Rd', '97140','George', 'WA', 'US')
where deptno=30

l

/

commit;

exec dbms_stats.gather_table_stats(user,'DEPTOBJ')

col dept_location format a60

select /*+ gather_plan_statistics parallel(e 2)*/
  d.dept_location, count(e.ename) ecount
from scott.emp e, deptobj d
where e.deptno = d.deptno
group by dept_location
order by dept_location

l

/

@showplan_last
