/* Listing 1-12 */

select c.customer_id cust_id, o.order_id ord_id, c.gender
from oe.customers c
join oe.orders o
on c.customer_id = o.customer_id;
