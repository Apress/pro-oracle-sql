PROMPT 
PROMPT Execution plan - ACYCLIC FAST
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
  select distinct product, country, year,week, sale_first_Week	
  from sales_fact
  where country in ('Australia') and product='Xtend Memory' 
  model return updated rows
  partition by (product, country)
  dimension by (year,week)
  measures ( 0 sale_first_week	,sale )
  rules automatic order(
     sale_first_week [2000,1] = 0.12*sale [2000, 1]
   )
   order by product, country,year, week
/

l
set lines 120 pages 100
select * from table (dbms_xplan.display_cursor('','','ALLSTATS LAST'));
