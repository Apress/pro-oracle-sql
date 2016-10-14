/* Listing 6-4 */

create table regions2
(region_id varchar2(10) primary key,
region_name varchar2(25));


insert into regions2
select * from regions;


variable regid number

exec :regid := 1

set autotrace traceonly explain

select /* DataTypeTest */ *
from regions2
where region_id = :regid;

set autotrace off

select /* DataTypeTest */ *
from regions2
where region_id = :regid;

@pln DataTypeTest


