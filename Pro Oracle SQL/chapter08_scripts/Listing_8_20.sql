PROMPT 
PROMPT Listagg function
PROMPT
  set lines 120 pages 100
  select listagg (country, ',') 
      within group (order by country desc)
     from (
      select distinct country from sales_fact
      order by country
   )
/
