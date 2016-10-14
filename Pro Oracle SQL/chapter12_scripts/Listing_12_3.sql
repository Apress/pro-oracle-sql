PROMPT 
PROMPT Nulls and indexes
PROMPT
drop table t1;
create table  t1 (n1 number, n2 varchar2(100) );
insert into t1 select object_id, object_name from dba_objects where rownum<101;
commit;
@analyze_table
create index t1_n1 on t1(n1);
select * from t1 where n1 is null;
@x
create index t1_n10 on t1(n1,0);
select * from t1 where n1 is null;
@x
