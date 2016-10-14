PROMPT
PROMPT Positional reference: Adding cells for Calendar_week_number
PROMPT     
PROMPT  ..Retrieving only for product='CD-R Mini Discs' and region='Asia' to improve clarity 
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
  where country in ('Australia') and product ='Xtend Memory'
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules automatic order(
       inventory [year, week ] =
                                 nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                  - sale[cv(year), cv(week) ] +
                                  + receipts [cv(year), cv(week) ],
       sale [2002, 1] = 0,
       receipts [ 2002,1] =0  
   )
  order by product, country,year, week
/


