PROMPT 
PROMPT ratio_to_report
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
  trunc(100*
         ratio_to_report(sale) over(partition by product, country, region ,year) 
        ,2) sales_yr,
  trunc(100*
         ratio_to_report(sale) over(partition by product, country, region)
        ,2) sales_prod
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'
  order by product, country,year, week
/
