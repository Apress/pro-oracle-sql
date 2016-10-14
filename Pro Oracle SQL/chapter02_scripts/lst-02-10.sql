/* Listing 2-10 */

set autotrace traceonly explain

SELECT p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
s.channel_id, s.promo_id, s.cust_id, s.amount_sold
FROM sales s, products p, times t
WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;

set autotrace off

CREATE MATERIALIZED VIEW sales_time_product_mv
ENABLE QUERY REWRITE AS
SELECT p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
s.channel_id, s.promo_id, s.cust_id, s.amount_sold
FROM sales s, products p, times t
WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;

set autotrace traceonly explain

SELECT p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
s.channel_id, s.promo_id, s.cust_id, s.amount_sold
FROM sales s, products p, times t
WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;

SELECT /*+ rewrite(sales_time_product_mv) */
p.prod_id, p.prod_name, t.time_id, t.week_ending_day,
s.channel_id, s.promo_id, s.cust_id, s.amount_sold
FROM sales s, products p, times t
WHERE s.time_id=t.time_id AND s.prod_id = p.prod_id;

