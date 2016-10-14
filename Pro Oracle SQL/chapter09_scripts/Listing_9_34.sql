PROMPT 
PROMPT More complex variation of Model clause
PROMPT
with t1 as (
  select  product, country, year, week, inventory, sale, receipts
  from sales_fact sf
  where country in ('Australia') and product='Xtend Memory'
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules automatic order(
       inventory [year, week ] order by year, week =
                                 nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                  - sale[cv(year), cv(week) ] +
                                  + receipts [cv(year), cv(week) ]
   )
)
select product, country, year, week , inventory, sale,receipts,
                        prev_sale
from t1
model return updated rows
partition by (product, country)
dimension by (year, week)
measures (inventory, sale, receipts,0 prev_sale)
rules sequential order ( 
  prev_sale [ year, week ] order by year, week = 
				nvl (sale [ cv(year) -1, cv(week)],0 )
)
/
