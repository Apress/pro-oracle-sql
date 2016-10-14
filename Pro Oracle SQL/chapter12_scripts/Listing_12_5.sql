PROMPT 
PROMPT Index Organized Tables
PROMPT

drop table sales_iot;
create table sales_iot  
  ( prod_id number not null, 
    cust_id number not null, 
    time_id date not null,
    channel_id number not null,
    promo_id number not null,
    quantity_sold number (10,2) not null,
    amount_sold number(10,2) not null,
    primary key  ( prod_id, cust_id, time_id, channel_id, promo_id)
 )
 organization index ;
insert into sales_iot select * from sales;
commit;
@analyze_table
select quantity_sold, amount_sold from sales_iot where
prod_id=13 and cust_id=2 and channel_id=3 and promo_id=999;
@x




