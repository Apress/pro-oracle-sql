PROMPT 
PROMPT Index access path 2
PROMPT
col region format A15
col product format A30
col week format 9999
col sale format 999999.99
col receipts format 999999.99
set lines 120 pages 100 
alter session set statistics_level=all;	
select product, year, week from sales_fact where product='Xtend Memory'
and  year=1998 and week=1;
@x  
select /*+ full(sales_fact) */ product, year, week from sales_fact where product='Xtend Memory'
and  year=1998 and week=1;
@x


