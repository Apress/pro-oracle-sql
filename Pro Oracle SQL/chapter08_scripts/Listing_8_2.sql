PROMPT 
PROMPT SUM function
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
    sum (sale) over(
          partition by product, country, region ,year
          order by week
	  rows between unbounded preceding and current row
           ) running_sum_ytd
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'
  order by product, country,year, week
/
