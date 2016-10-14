PROMPT 
PROMPT Invisible indexes
PROMPT

column index_name format A30
set lines 120 pages 100

drop index sales_fact_c1;
create index sales_fact_c1 on sales_fact ( product, year , week) ; 

set termout off
select * from  (
 select * from sales_fact where product = 'Xtend Memory' and year=1998 and week=1
) where rownum <21 
;
set termout on
@x
alter index sales_fact_c1 invisible;
set termout off
select * from  (
 select * from sales_fact where product = 'Xtend Memory' and year=1998 and week=1
) where rownum <21 
;
set termout on
@x

alter session set optimizer_use_invisible_indexes =true;
set termout off
select * from  (
 select * from sales_fact where product = 'Xtend Memory' and year=1998 and week=1
) where rownum <21 
;
set termout on
@x
