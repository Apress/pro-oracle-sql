
set timing on

with sales_countries as (
	select /*+ gather_plan_statistics */
		cu.cust_id
		, co.country_name
	from	sh.countries co, sh.customers cu
	where cu.country_id = co.country_id
),
top_sales as (
	select 
		p.prod_name 
		, sc.country_name
		, s.channel_id
		, t.calendar_quarter_desc
		, s.amount_sold
		, s.quantity_sold
	from
		sh.sales s
		join sh.times t on t.time_id = s.time_id
		join sh.customers c on c.cust_id = s.cust_id
		join sales_countries sc on sc.cust_id = c.cust_id
		join sh.products p on p.prod_id = s.prod_id
),
sales_rpt as (
	select
		prod_name product
		, country_name country
		, channel_id channel
		, substr(calendar_quarter_desc, 6,2) quarter
		, sum(amount_sold) amount_sold
		, sum(quantity_sold) quantity_sold 
	from top_sales
	group by 
		prod_name
		, country_name
		, channel_id
		, substr(calendar_quarter_desc, 6, 2)
)
select * from
( 
  select product, channel, quarter, country, quantity_sold
  from sales_rpt
) pivot (
	sum(quantity_sold)
	for (channel, quarter) in
	(
		(5, '02') as catalog_q2,
		(4, '01') as internet_q1,
		(4, '04') as internet_q4,
		(2, '02') as partners_q2,
		(9, '03') as tele_q3
	)
)
order by product, country
/

