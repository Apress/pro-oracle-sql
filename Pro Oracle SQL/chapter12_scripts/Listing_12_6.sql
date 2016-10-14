PROMPT 
PROMPT Index Organized Tables - Secondary indexes
PROMPT

drop index sales_iot_sec ;
create index sales_iot_sec on
 sales_iot (channel_id, time_id, promo_id, cust_id) ;

select quantity_sold, amount_sold from sales_iot where
channel_id=3 and promo_id=999 and cust_id=12345 and time_id='30-JAN-00';
@x

col segment_name format A30
select segment_name, sum( bytes/1024/1024) sz from dba_segments
where segment_name in ('SALES_IOT_PK','SALES_IOT_SEC')
group by segment_name
/




