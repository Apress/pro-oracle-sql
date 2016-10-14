PROMPT
PROMPT MODEL clause -- This should work fine.. ORDER BY YEAR,WEEK added
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
  select product, country, year, week, inventory, sale, receipts
  from sales_fact
  where country in ('Australia')
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules (
       inventory [year, week ] order by year, week =
                                 nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                  - sale[cv(year), cv(week) ] +
                                  + receipts [cv(year), cv(week) ]
   )
  order by product, country,year, week
/

