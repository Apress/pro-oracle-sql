--- order_reports_all.sql
set linesize 115 

column order_id new_value v_order noprint 
column order_date new_value v_o_date noprint 
column line_no format 99 
column order_total format 999,999,999.99

BREAK ON order_id SKIP 2 PAGE 
BTITLE OFF

compute sum of line_item_total on order_id

ttitle left 'Order ID: ' v_order	- 
       right 'Order Date: ' v_o_date	-
       skip 2

spool logs/order_reports_all.txt

select h.order_id ORDER_ID, 
       h.order_date, 
       li.line_item_id line_no, 
       li.product_name, 
       li.supplier_product_id ITEM_NO, 
       li.unit_price, 
       li.discount_price, 
       li.quantity,
       li.line_item_total  from order_detail_header h, order_detail_line_item li
 where h.order_id = li.order_id order by h.order_id, li.line_item_id ;

spool off