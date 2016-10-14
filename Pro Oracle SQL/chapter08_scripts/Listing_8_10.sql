PROMPT 
PROMPT NTH_VALUE function 
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
    select year, week, sale,
       nth_value ( sale, 2) over (
        partition by product,country, region, year
        order by sale desc
        rows between unbounded preceding and unbounded following
       ) sale_2nd_top
    from sales_fact
    where country in ('Australia') and product='Xtend Memory'
   order by product, country , year, week
/
