PROMPT 
PROMPT Compressed index 
PROMPT
  col region format A15
  col product format A30
  col week format 9999
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100 
  select * from  ( 
    select product, year,week, sale 
    from sales_fact
    order by product, year,week
  ) where rownum <21;
  drop index sales_fact_c1;
  create index sales_fact_c1 on sales_fact ( product, year, week);
  set head off
  select 'Compressed index size (MB) :' ||trunc(bytes/1024/1024, 2) from user_segments
  where segment_name='SALES_FACT_C1';
  set head on
  drop index sales_fact_c1;
  create index sales_fact_c1 on sales_fact ( product, year, week) 
  compress 2;
  set head off
  select 'Compressed index size (MB) :' ||trunc(bytes/1024/1024,2) from user_segments
  where segment_name='SALES_FACT_C1';
  set head on


