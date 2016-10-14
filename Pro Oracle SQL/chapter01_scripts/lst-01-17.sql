/* Listing 1-17 */

create table small_customers 
(customer_id	number,
 sum_orders		number)
;


create table medium_customers 
(customer_id	number,
 sum_orders		number)
;


create table large_customers 
(customer_id	number,
 sum_orders		number)
;


select * from small_customers ;

select * from medium_customers ;

select * from large_customers ;

insert all
when sum_orders < 10000 then
into small_customers
when sum_orders >= 10000 and sum_orders < 100000 then
into medium_customers
else
into large_customers
select customer_id, sum(order_total) sum_orders
from oe.orders
group by customer_id ;


select * from small_customers ;

select * from medium_customers ;

select * from large_customers ;

