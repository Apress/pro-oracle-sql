--- Execute in Session A

set transaction isolation level serializable;
variable o number 
execute :o := &order_id variable d number 
execute :d := &discount 

--- Add new ordered item and reduce on-hand inventory
variable i number 
execute :i := &first_item variable q number 
execute :q := &item_quantity variable p number 
execute :p := get_ListPrice(:i)insert into order_items 
 (order_id, line_item_id, product_id, unit_price, discount_price, quantity)   values (:o, 1, :i, :p, :p-(:p*:d), :q) ;

update inventories
   set quantity_on_hand = quantity_on_hand - :q
 where product_id = :i and warehouse_id = 1 ;
pause 

--- Execute in Session Bvariable o number 
execute :o := &order_id variable s number 
execute :s := &status 

update orders set order_status = :swhere order_id = :o ; 

select order_id,
       customer,
       mobile, status,
       order_total,
       order_date
  from order_detail_header where order_id = :o;
select line_item_id,
       product_name,
       unit_price,
       discount_price,
       quantity,
       line_item_total  from order_detail_line_item
 where order_id = :o
 order by line_item_id ;

commit;

--- Execute in Session A

--- Get New Order Totalvariable t number 
execute :t := get_OrderTotal(:o)

--- Update order totalupdate orders set order_total = :t where order_id = :o ; 

