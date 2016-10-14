PROMPT 
PROMPT Bitmap indexes
PROMPT
drop index sales_fact_part_bm1;
drop index sales_fact_part_bm2;

create bitmap index sales_fact_part_bm1 on sales_fact_part ( country ) Local; 
create bitmap index sales_fact_part_bm2 on sales_fact_part ( region )  Local ; 

set termout off
select * from sales_fact_part where country='Spain' and
region='Western Europe' ;
set termout on
@x