PROMPT 
PROMPT Virtual indexes
PROMPT
create index sales_virt on sales ( cust_id, promo_id) nosegment;
 alter session set "_use_nosegment_indexes"=true;
explain plan for  select * from sales where cust_id=:b1 and promo_id=:b2
/
select * from table(dbms_xplan.display(null,'','all'))
/



