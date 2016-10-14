savepoint create_order;

insert into orders
 (order_id, order_date, order_mode, order_status, customer_id, sales_rep_id)   values (2459, sysdate, 'direct', 1, 141, 145) ; 

--- Add first ordered item and reduce inventory 

savepoint detail_item1 ; 

insert into order_items (order_id, line_item_id, product_id, unit_price, discount_price, quantity)   values (2459, 1, 2255, 775, 658.75, 5) ; 

update inventories
   set quantity_on_hand = quantity_on_hand - 5
 where product_id = 2255
   and warehouse_id = 1 ;

--- Add second ordered item and reduce inventory 

savepoint detail_item2; 
insert into order_items
 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)   values (2459, 2, 2274, 161, 136.85, 5) ; 

update inventories
   set quantity_on_hand = quantity_on_hand - 5
 where product_id = 2274
   and warehouse_id = 1 ;

--- Add third ordered item and reduce inventory

savepoint detail_item3;

insert into order_items
 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)   values (2459, 3, 2537, 200, 170, 19) ; 

update inventories
   set quantity_on_hand = quantity_on_hand - 19
 where product_id = 2537
   and warehouse_id = 1 ;

--- Request credit authorization 

savepoint credit_auth; 

exec billing.credit_request(141,7208) ; 

savepoint order_total; 

--- Update order total 

savepoint order_total;

update orders
   set order_total = 7208
 where order_id = 2459; 

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
       line_item_total
       order_detail_line_items  from order
 where order_id = 2459
 order by line_item_id ;
rollback to savepoint detail_item1; 
