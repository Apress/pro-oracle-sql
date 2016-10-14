
-- cube on sales
-- demo use of GROUPING_ID() in HAVING

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

spool l_7_18.txt


set echo on

variable N_ALL_DATA number
variable N_AGE_RANGE number
variable N_INCOME_LEVEL number
variable N_SUMMARY number

begin
  -- set values to 0 to disable
  :N_ALL_DATA     := 0; -- 1 to enable
  :N_AGE_RANGE    := 2; -- 2 to enable
  :N_INCOME_LEVEL := 0; -- 3 to enable
  :N_SUMMARY      := 4; -- 4 to enable
end;	
/

set echo off

with tsales as (
select /*+ gather_plan_statistics */
    s.quantity_sold
    , s.amount_sold
    , to_char(mod(cust_year_of_birth,10) * 10 ) || '-' ||
      to_char((mod(cust_year_of_birth,10) * 10 ) + 10) age_range
    , c.cust_income_level
    , p.prod_name
    , p.prod_desc
    , p.prod_category
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
)
select
  'Q' || to_char(grouping_id(cust_income_level,age_range)+1) query_tag
  , prod_category
  , decode(grouping(cust_income_level),1,'ALL INCOME',cust_income_level) cust_income_level 
  , decode(grouping(age_range),1,'ALL AGE',age_range) age_range
  , sum(profit) profit
from tsales
group by prod_category, cube(cust_income_level,age_range)
  having grouping_id(cust_income_level,age_range)+1 
    in(:N_ALL_DATA,:N_AGE_RANGE,:N_INCOME_LEVEL,:N_SUMMARY)
order by prod_category, profit

l

/

-- @showplan_last

spool off

