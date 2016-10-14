PROMPT 
PROMPT Bitmap join indexes
PROMPT

alter table products modify primary key validate;
alter table customers modify primary key validate;
alter table channels modify primary key validate;

create bitmap index sales_bji1 on sales ( p.prod_name, c.cust_first_name, ch.channel_desc)
from sales s, products p, customers c, channels ch
where s.prod_id = p.prod_id and
      s.cust_id = c.cust_id and
      s.channel_id = ch.channel_id 
LOCAL
/
