PROMPT 
PROMPT Reverse Key indexes
PROMPT

drop index sales_fact_part_n1;

create unique index sales_fact_part_n1 on sales_fact_part ( id ) global  reverse ; 
select * from sales_fact_part where id=1000;
@x
set termout off
select * from sales_fact_part where id between 1000 and 1001;
set termout on
@x
