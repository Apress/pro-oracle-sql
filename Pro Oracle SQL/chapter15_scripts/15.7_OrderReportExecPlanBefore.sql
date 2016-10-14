--- Order Report Execution Plan (Before) 
@formats.sql

alter session set statistics_level = 'ALL';

set linesize 105

column order_id new_value v_order noprint 
column order_date new_value v_o_date noprint 
column ID format 99 
column order_total format 999,999,999.99

BREAK ON order_id SKIP 2 PAGE 
BTITLE OFF

compute sum of line_item_total on order_id

ttitle left 'Order ID: ' v_order	- 
       right 'Order Date: ' v_o_date	- 
       skip 2
spool logs/order_report_all_pre.txt

select /* OrdersPreChange */ h.order_id ORDER_ID,
       order_date,
       li.line_item_id ID,
       li.product_name,
       li.product_id ITEM_NO,
       li.unit_price,
       li.discount_price,
       li.quantity,
       li.line_item_total    from order_detail_header h, order_detail_line_items li
   and h.order_id = li.order_id
 order by h.order_id, li.line_item_id ;

spool off

set lines 150 

spool logs/OrdersPreChange.txt

@pln.sql OrdersPreChange