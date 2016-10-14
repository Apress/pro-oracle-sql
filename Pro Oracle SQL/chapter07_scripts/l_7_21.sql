
-- rollup

col prod_category format a30 head 'PRODUCT CATEGORY'
col amount_sold format $99,999,99.00 head 'AMT SOLD'
col cust_name format a30 head 'CUSTOMER'

spool l_7_21.txt

with mysales as (
  select 
    c.cust_last_name ||',' || c.cust_first_name cust_name
    , p.prod_category
    , to_char(trunc(time_id,'YYYY'),'YYYY') sale_year
    , p.prod_name
    , s.amount_sold
  from sh.sales s
  join sh.products p on p.prod_id = s.prod_id
  join sh.customers c on c.cust_id = s.cust_id
  where c.cust_last_name like 'Sul%'
  --where s.time_id = to_date('01/01/2001','mm/dd/yyyy')
)
select
  decode(grouping(m.cust_name),1,'GRAND TOTAL',m.cust_name) cust_name
  , decode(grouping(m.sale_year),1,'TOTAL BY YEAR',m.sale_year) sale_year
  , decode(grouping(m.prod_category),1,'TOTAL BY CATEGORY',m.prod_category) prod_category
  , sum(m.amount_sold) amount_sold
from mysales m
group by rollup(m.cust_name, m.prod_category, m.sale_year)
order by grouping(m.cust_name), 1,2,3

l

/

spool off

