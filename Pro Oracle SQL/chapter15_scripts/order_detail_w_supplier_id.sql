create or replace view order_items_w_supplier
   as
select oi.order_id, 
       oi.line_item_id, 
       pi.product_id,
       pi.supplier_product_id,
       pi.product_name, 
       oi.quantity, 
       oi.unit_price, 
       oi.discount_price, 
      (oi.quantity*oi.discount_price) LINE_ITEM_TOTAL
  from product_information pi, order_items oi
 where oi.product_id = pi.product_id
 order by oi.order_id, oi.line_item_id ;

