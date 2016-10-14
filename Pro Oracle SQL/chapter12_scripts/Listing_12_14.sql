PROMPT 
PROMPT Function based indexes
PROMPT
drop index sales_fact_part_fbi1;
select * from sales_fact_part where to_char(id)='1000';
@x
create index sales_fact_part_fbi1 on sales_fact_part( to_char(id)) 
;
@analyze_table_sfp
select * from sales_fact_part where to_char(id)='1000';
@x
