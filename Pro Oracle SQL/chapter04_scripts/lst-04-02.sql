/* Listing 4-2 */

select customer_id, order_date
from orders
where customer_id = 102 ;

select customer_id, order_date,
lag(order_date,1,order_date)
over (partition by customer_id order by order_date)
as prev_order_date
from orders
where customer_id = 102;

select trunc(order_date) - trunc(prev_order_date) days_between
from                                                        
(                                                    
select customer_id, order_date,                    
lag(order_date,1,order_date)                       
over (partition by customer_id order by order_date)
as prev_order_date                                 
from orders                                        
where customer_id = 102                            
);  

select avg(trunc(order_date) - trunc(prev_order_date)) avg_days_between
from
(
select customer_id, order_date,
lag(order_date,1,order_date)
over (partition by customer_id order by order_date)
as prev_order_date
from orders
where customer_id = 102
);                                            

