PROMPT 
PROMPT Index access path
PROMPT
col region format A15
col product format A30
col week format 9999
col sale format 999999.99
col receipts format 999999.99
set lines 120 pages 100 
alter session set statistics_level=all;	
drop index sales_fact_c2;
create index sales_fact_c2 on sales_fact ( country);
set head off
select count(distinct(region)) from sales_fact s where country='Spain'   ;
@x  
select /*+ index ( s sales_fact_c2) */ count(distinct(region)) from sales_fact s where country='Spain'   ;
@x


