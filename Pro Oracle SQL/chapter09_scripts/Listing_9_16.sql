PROMPT
PROMPT MODEL clause -- Aggregation..
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
  select product, country, year, week, inventory,avg_inventory, max_sale
      from sales_fact
      where country in ('Australia') and product ='Xtend Memory'
      model return updated rows
      partition by (product, country)
      dimension by (year, week)
      measures ( 0 inventory , 0 avg_inventory ,0 max_sale, sale, receipts)
      rules automatic order(
           inventory [year, week ] =
                                    nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                     - sale[cv(year), cv(week) ] +
                                     + receipts [cv(year), cv(week) ],
	    avg_inventory [ year,ANY ] = avg (inventory) [ cv(year), week ],
            max_Sale [ year, ANY ]   = max( sale) [ cv(year), week ]
       )
    order by product, country,year, week
/