PROMPT 
PROMPT Nesting analytic functions
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
select  year, week, top_sale_year,
   lag( top_sale_year) over ( order by year desc) prev_top_sale_yer
from (
 select distinct
    first_value ( year) over ( 
          partition by product, country, region ,year
          order by sale desc
          rows between unbounded preceding and unbounded following
     ) year,
    first_value ( week) over ( 
          partition by product, country, region ,year
          order by sale desc
          rows between unbounded preceding and unbounded following
     ) week,
    first_value (sale) over(
          partition by product, country, region ,year
          order by sale desc
          rows between unbounded preceding and unbounded following
     ) top_sale_year
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'
)
  order by year, week
/
