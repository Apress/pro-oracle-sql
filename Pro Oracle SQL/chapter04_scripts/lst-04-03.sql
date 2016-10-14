/* Listing 4-3 */

select (max(trunc(order_date)) - min(trunc(order_date))) / count(*) as avg_days_between
from orders
where customer_id = 102 ;

