PROMPT 
PROMPT Global partitioned index
PROMPT

create index sales_fact_part_n1 on sales_fact_part (year)
global partition by range ( year)
  (partition p_1998 values less than (1999),
   partition p_2000 values less than (2001),
   partition p_max values less than  (maxvalue)
)
/

col region format A15
  col product format A30
  col week format 9999
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100 
set serveroutput off

select * from  (
 select * from sales_fact_part where product = 'Xtend Memory' and year=1998
) where rownum <21 
;
@x