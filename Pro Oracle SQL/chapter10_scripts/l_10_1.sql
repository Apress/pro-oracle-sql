
set timing on

select *
from (
	select /*+ gather_plan_statistics */
		product
		, channel
		, quarter
		, country
		, quantity_sold
	from
	(
		select
			prod_name product
			, country_name country
			, channel_id channel
			, substr(calendar_quarter_desc, 6,2) quarter
			, sum(amount_sold) amount_sold
			, sum(quantity_sold) quantity_sold
		from
			sh.sales
			join sh.times on times.time_id = sales.time_id
			join sh.customers on customers.cust_id = sales.cust_id
			join sh.countries on countries.country_id = customers.country_id
			join sh.products on products.prod_id = sales.prod_id
		group by
		  prod_name
		  , country_name
		  , channel_id
		  , substr(calendar_quarter_desc, 6, 2)
	)
) PIVOT (
	sum(quantity_sold)
	FOR (channel, quarter) IN
	(
		(5, '02') AS CATALOG_Q2,
		(4, '01') AS INTERNET_Q1,
		(4, '04') AS INTERNET_Q4,
		(2, '02') AS PARTNERS_Q2,
		(9, '03') AS TELE_Q3
	)
)
order by product, country
/
