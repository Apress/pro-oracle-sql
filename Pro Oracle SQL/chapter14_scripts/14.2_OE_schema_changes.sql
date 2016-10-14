-- create 'billing' user to own a credit authorization procedure
conn / as sysdba 

create user billing identified by &passwd ;

grant create session to billing ;
grant create procedure to billing ;

--- add warehouses and inventory using a random number to populate inventory quantities 

connect oe 

insert into warehouses values (1, 'Finished Goods', 1400) ;

insert into inventories
select product_id, 1, round(dbms_random.value(2, 5000),0)  from product_information; 

commit;

--- check total quantity on hand 

select sum(quantity_on_hand) from inventories; 

--- create a sequence for the order id 

create sequence order_id start with 5000;

--- create a table for order status
create table oe.order_status
 (  order_status          number(2, 0) not null,
  order_status_name     varchar2(12) not null, 
  constraint order_status_pk order_status));
--- add values for order status 1 through 10 to match existing sample data
insert into order_status (order_status, order_status_name) values (0, 'Pending');
insert into order_status (order_status, order_status_name) values (1, 'New');
insert into order_status (order_status, order_status_name) values (2, 'Cancelled');
insert into order_status (order_status, order_status_name) values (3, 'Authorized');
insert into order_status (order_status, order_status_name) values (4, 'Processing'); 
insert into order_status (order_status, order_status_name) values (5, 'Shipped'); 
insert into order_status (order_status, order_status_name) values (6, 'Delivered'); 
insert into order_status (order_status, order_status_name) values (7, 'Returned'); 
insert into order_status (order_status, order_status_name) values (8, 'Damaged'); 
insert into order_status (order_status, order_status_name) values (9, 'Exchanged'); 
insert into order_status (order_status, order_status_name) values (10, 'Rejected');

--- create a function to get the list prices of order items 

@get_listprice.fnc 

--- create a function to get the order total 

@get_ordertotal.fnc

--- create a function to get the order count 

@get_orderitemcount.fnc 

--- create order detail views 

@order_detail_views.sql

--- Create credit_request procedure connect billing 

@credit_request.sql
