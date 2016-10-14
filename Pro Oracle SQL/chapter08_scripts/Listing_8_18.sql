PROMPT 
PROMPT NTILE
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
   ntile (10) over(
          partition by product, country, region , year 
          order by sale desc
          ) group#
  from sales_fact
  where country in ('Australia')  and product ='Xtend Memory'

/