/* Listing 3-23 */

select c.cust_last_name, nvl(sum(o.order_total),0) tot_orders
from customers c, orders o
where c.customer_id = o.customer_id
group by c.cust_last_name
having nvl(sum(o.order_total),0) between 0 and 5000
order by c.cust_last_name ;

select count(*) ct
from
(
select c.cust_last_name, nvl(sum(o.order_total),0) tot_orders
from customers c, orders o
where c.customer_id = o.customer_id
group by c.cust_last_name
having nvl(sum(o.order_total),0) between 0 and 5000
order by c.cust_last_name
);

select count(*) ct
from
(
select c.cust_last_name, nvl(sum(o.order_total),0) tot_orders
from customers c, orders o
where c.customer_id = o.customer_id(+)
group by c.cust_last_name
having nvl(sum(o.order_total),0) between 0 and 5000
order by c.cust_last_name
);

set autotrace traceonly explain

/


