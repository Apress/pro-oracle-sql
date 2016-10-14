
set linesize 200
set serveroutput off
set timing on

col cust_id format 99999999 head 'CUST ID'
col prod_category format a30 head 'PRODUCT CATEGORY'
col cust_first_name format a15 head 'FIRST NAME'
col cust_last_name format a15 head 'LAST NAME'
col total_sale format 999,999,999.90 head 'TOTAL SALE'

break on report
compute sum of total_sale on report

set term off 

spool l_10_11.txt

with custyear as (
	select cust_id, extract(year from time_id) sales_year
	from sh.sales
	where extract(year from time_id) between 1998 and 2002
	group by cust_id,  extract(year from time_id)
),
custselect as (
	select distinct cust_id
	from (
		select cust_id, count(*) over ( partition by cust_id) year_count
		from custyear
	)
	where  year_count >= 3 -- 3 or more years as a customer during period
)
select cu.cust_id, cu.cust_last_name, cu.cust_first_name, p.prod_category, sum(co.unit_price * s.quantity_sold) total_sale
from custselect cs
join sh.sales s on s.cust_id = cs.cust_id
join sh.products p on p.prod_id = s.prod_id
join sh.costs co on co.prod_id = s.prod_id
	and co.time_id = s.time_id
join sh.customers cu on cu.cust_id = cs.cust_id
group by cu.cust_id, cu.cust_last_name, cu.cust_first_name, p.prod_category
order by cu.cust_id

l

/

spool off

set term on

