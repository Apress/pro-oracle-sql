set termout off
alter session set nls_date_format = 'dd Mon yyyy';

column customer format a25
column sales_rep format a25
column mobile format a15
column item format 9999
column product_name format a35
column unit_price format 99,999.99
column discount_price format 99,999.99
column line_item_total format 99,999.99
column order_total format 99,999,999.99

set termout on

