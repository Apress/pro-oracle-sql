select order_id,
       customer,
       mobile,
       status,
       order_total,
       order_date
  from order_detail_header where order_id = 2459;

select line_item_id, 
       product_name, 
       unit_price, 
       discount_price, 
       quantity,
       line_item_total  from order_detail_line_items
 where order_id = 2459
 order by line_item_id ;

select product_id,
       quantity_on_hand
  from inventories where product_id in (2255, 2274, 2537) 
 order by product_id ;