PROMPT
PROMPT IGNORE NAV
PROMPT     
PROMPT  
 col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
  select product, country, year, week,  sale
  from sales_fact
  where country in ('Australia') and product ='Xtend Memory'
  model IGNORE NAV return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( sale)
  rules sequential order(
    sale[2001,1] = sale[2001,1],
    sale [ 2002, 1] = sale[2001,1] + sale[2002,1]
    )
  order by product, country,year, week
/


