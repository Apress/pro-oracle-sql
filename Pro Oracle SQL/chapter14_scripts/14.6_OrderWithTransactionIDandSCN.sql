insert into orders  (order_id, order_date, order_mode, order_status, customer_id, sales_rep_id)    values
  (2459, sysdate, 'direct', 1, 141, 145) ;

select current_scn from v$database ;select xid, status from v$transaction ;
--- Update order total 

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
  from order_detail_line_items
 where order_id = 2459 order by line_item_id ;

select current_scn from v$database ;select xid, status from v$transaction ;
rollback; 

select current_scn from v$database ;select xid, status from v$transaction ;
