/* Listing 6-15 */

create table my_objects as
select * from all_objects;

exec dbms_stats.gather_table_stats(user,'MY_OBJECTS',estimate_percent=>100,cascade=>true,method_opt=>'FOR ALL COLUMNS SIZE 1');

insert into my_objects
select * from all_objects;

insert into my_objects
select * from all_objects;

insert into my_objects
select * from all_objects;

insert into my_objects
select * from all_objects;

insert into my_objects
select * from all_objects;


select column_name, num_distinct, density
from user_tab_cols
where table_name = 'MY_OBJECTS' ;


select /* KM7 */ object_id, object_name
from my_objects
where object_type = 'TABLE';

@pln KM7

select num_rows
from dba_tables
where table_name = 'MY_OBJECTS';

exec dbms_stats.gather_table_stats(user,'MY_OBJECTS',estimate_percent=>100, cascade=>true,method_opt=>'FOR ALL COLUMNS SIZE 1');

select /* KM8 */ object_id, object_name
from my_objects
where object_type = 'TABLE';

@pln KM8

exec dbms_stats.gather_table_stats(user,'MY_OBJECTS',estimate_percent=>100, cascade=>true,method_opt=>'FOR ALL COLUMNS SIZE AUTO');

select /* KM9 */ object_id, object_name
from my_objects
where object_type = 'TABLE';

@pln KM9

