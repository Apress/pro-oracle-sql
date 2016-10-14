PROMPT 
PROMPT Lag function with offset of 10
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
 select  year, week,sale, 
    lag(sale, 10,sale) over(
          partition by product, country, region 
          order by year, week
     ) prior_wk_sales_10
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'
  order by product, country,year, week
/
