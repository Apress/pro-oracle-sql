create or replace view order_detail_header
   as
select c.cust_first_name||' '||c.cust_last_name CUSTOMER, 
       c.phone_number MOBILE,
       o.order_id, 
       o.order_date, 
       o.order_mode, 
      os.order_status_name STATUS, 
       o.order_total,
       e.last_name SALES_REP
  from customers c, orders o, order_status os, hr.employees e
 where c.customer_id = o.customer_id
   and o.order_status = os.order_status
   and o.sales_rep_id = e.employee_id
 order by c.cust_last_name, c.cust_first_name, o.order_id ;


create or replace view order_detail_line_items
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

