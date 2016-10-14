/* Listing 3-24 */


select count(*) ct
from
(
select c.cust_last_name, nvl(sum(o.order_total),0) tot_orders
from customers c
left outer join
orders o
on (c.customer_id = o.customer_id)
group by c.cust_last_name
having nvl(sum(o.order_total),0) between 0 and 5000
order by c.cust_last_name
);
