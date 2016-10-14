PROMPT 
PROMPT Local index execution plan
PROMPT

drop table sales_fact_part;
CREATE table sales_fact_part 
partition by range ( year )
( partition p_1997 values less than ( 1998) ,
  partition p_1998 values less than ( 1999),
  partition p_1999 values less than (2000),
  partition p_2000 values less than (2001),
  partition p_max values less than (maxvalue)
)
AS 
SELECT * from sales_fact;

create index sales_fact_part_n1 on sales_fact_part( product, year)
local;

  col region format A15
  col product format A30
  col week format 9999
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100 
set serveroutput off
select * from  (
 select * from sales_fact_part where product = 'Xtend Memory'
) where rownum <21 
;
@x
select * from  (
 select * from sales_fact_part where product = 'Xtend Memory' and year=1998
) where rownum <21 
;
@x