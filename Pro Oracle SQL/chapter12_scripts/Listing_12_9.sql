PROMPT 
PROMPT Hash partitioning
PROMPT
drop sequence sfseq;
create sequence sfseq cache 200;

drop table sales_fact_part;

CREATE table sales_fact_part 
partition by hash ( id )
partitions 32
AS 
SELECT sfseq.nextval id , f.* from sales_fact f;

create unique index sales_fact_part_n1 on sales_fact_part( id )
local;

col region format A15
col product format A30
col week format 9999
col sale format 999999.99
col receipts format 999999.99
set lines 120 pages 100 

set serveroutput off

 select * from sales_fact_part where id =1000;

@x
