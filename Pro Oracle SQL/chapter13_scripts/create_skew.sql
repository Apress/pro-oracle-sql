create table skew
(pk_col number primary key, 
col1 number,
col2 varchar2 (30),
col3 date,
col4 varchar2(1))
/
create sequence skew_seq
/
begin
for i in 1..100000 loop
insert into skew (pk_col, col1, col2, col3, col4)
select skew_seq.nextval, skew_seq.currval, 'asddsadasd', 
sysdate-(skew_seq.currval/3600), 'Y' from dual;
end loop;
end;
/
select count(*) from skew;
update skew set col1 = 1 where rownum < 100000;
update skew set col4 = 'N' where rownum < 100;
commit;

create or replace package skew_package as
skew_record skew%rowtype;
end;
/

