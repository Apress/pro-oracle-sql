PROMPT
PROMPT MODEL clause -- Rule evaluation order with automatic order
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
  select * from  (
  select product, country, year, week, inventory, sale, receipts
  from sales_fact
  where country in ('Australia') and product in ('Xtend Memory')
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules automatic order (
      inventory [year, week ] order by year, week  =
                                 nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                  - sale[cv(year), cv(week) ] +
                                  + receipts [cv(year), cv(week) ],
      receipts [ year in (2000,2001), week in (51,52,53) ] order by year, week
                  = receipts [cv(year), cv(week)] * 10 
      )
   order by product, country,year, week
  ) where week >50
/

