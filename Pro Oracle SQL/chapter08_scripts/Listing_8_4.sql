PROMPT 
PROMPT Max function - analytical mode - 5 weeks window
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
    max (sale) over(
          partition by product, country, region ,year
          order by year, week
	  rows between 2 preceding and 2 following 
           ) max_weeks_5
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'
  order by product, country,year, week
/
