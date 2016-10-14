
set feed off term off echo off

-- removed by parent shell
host touch ./child_&1..lock

declare
	i integer;
begin

	lock table semaphore in share mode;

	for x in 1..200
	loop
select count(*) into i from (
with sales_countries as (
	select /*+ gather_plan_statistics */
		cu.cust_id
		, co.country_name
	from	sh.countries co, sh.customers cu
	where cu.country_id = co.country_id
),
top_sales as (
	select
		prod_name
		, country_name
		, channel_id
		, calendar_quarter_desc
		, amount_sold
	, quantity_sold
	from
		sh.sales
		join sh.times on times.time_id = sales.time_id
		join sh.customers on customers.cust_id = sales.cust_id
		join sh.countries on countries.country_id = customers.country_id
		join sh.products on products.prod_id = sales.prod_id
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
  select product, channel, quarter, quantity_sold
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
order by product
);
	end loop;

	-- release lock
	commit;

	-- don't exit till master lock released
	lock table exit_semaphore in share mode;
	commit;

end;
/

exit;


