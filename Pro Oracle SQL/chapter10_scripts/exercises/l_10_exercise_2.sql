

set timing on
set autotrace on statistics

set pagesize 60
set serveroutput off
set line 200
col age_range format a8 head 'AGE|RANGE'
col cust_income_level format a20 head 'INCOME LEVEL'
col channel_desc format a12 head 'CHANNEL'
col prod_name format a50 head 'PRODUCT'
col prod_desc format a52 head 'PRODUCT DESCRIPTION'
col prod_category format a30 head 'PRODUCT CATEGORY'
col quantity_sold format 9,999,990 head 'QTY SOLD'
col amount_sold format $99,999,99.00 head 'AMT SOLD'
col total_cost format $99,999,99.00 head 'TOTAL COST'
col profit format $99,999,999.00 head 'PROFIT'
col query_tag  format a6 head 'QUERY|TAG'

clear breaks

spool l_10_exercise_2.txt

	--/*+ materialize gather_plan_statistics */
	
with tsales as (
select 
	/*+ inline gather_plan_statistics */
    s.quantity_sold, s.amount_sold
    , c.cust_income_level, p.prod_category
    , (pf.unit_cost * s.quantity_sold)  total_cost
    , s.amount_sold - (pf.unit_cost * s.quantity_sold)  profit
  from sh.sales s
  join sh.customers c on c.cust_id = s.cust_id
  join sh.products p on p.prod_id = s.prod_id
  join sh.times t on t.time_id = s.time_id
  join sh.costs pf on
    pf.channel_id = s.channel_id
    and pf.prod_id = s.prod_id
    and pf.promo_id = s.promo_id
    and pf.time_id = s.time_id
  where  (t.fiscal_year = 2001)
),
profit05 as (
	select prod_category, profit 
	from (
		select t.prod_category, sum(t.profit) * .05 profit
		from tsales t
		group by prod_category
	)
),
high_profit_brackets as (
	select
	  t1.prod_category
	  , t1.cust_income_level
	  , sum(t1.profit) profit
	from tsales t1
	group by prod_category, t1.cust_income_level
	having sum(t1.profit) > (
		select pf5.profit
		from profit05 pf5
		where pf5.prod_category = t1.prod_category
	)
)
select * from high_profit_brackets
order by profit

l

/

@showplan_last

spool off

