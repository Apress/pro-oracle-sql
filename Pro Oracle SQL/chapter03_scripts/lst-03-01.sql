/* Listing 3-1 */

create table t1 as
select trunc((rownum-1)/100) id,
rpad(rownum,100) t_pad
from dba_source
where rownum <= 10000;

create index t1_idx1 on t1(id);

exec dbms_stats.gather_table_stats(user,'t1',method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);

create table t2 as
select mod(rownum,100) id,
rpad(rownum,100) t_pad
from dba_source
where rownum <= 10000;

create index t2_idx1 on t2(id);

exec dbms_stats.gather_table_stats(user,'t2',method_opt=>'FOR ALL COLUMNS SIZE 1',cascade=>TRUE);


