PROMPT 
PROMPT Bitmap join indexes
PROMPT
drop index sales_bji1;
select sum(s.quantity_sold), sum(s.amount_sold) 
  from sales s, products p, customers c, channels ch
where s.prod_id = p.prod_id and
     s.cust_id = c.cust_id and
     s.channel_id = ch.channel_id and
     p.prod_name='Y box' and
     c.cust_first_name='Abigail' and 
     ch.channel_desc = 'Direct_sales'
/
@x