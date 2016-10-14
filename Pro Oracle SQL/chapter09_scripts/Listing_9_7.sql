PROMPT
PROMPT Symbolic reference- updates only 
PROMPT     
PROMPT  
  col product format A12
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
  select product, country, year, week, sale
  from sales_fact
  where country in ('Australia') and product ='Xtend Memory'
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( sale)
  rules(
         sale [ year in (2000,2001), week in (1,52,53) ] order by year, week
                  = sale [cv(year), cv(week)] * 1.10
  )
  order by product, country,year, week
/