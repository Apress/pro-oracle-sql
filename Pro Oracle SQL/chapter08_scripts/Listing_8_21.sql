PROMPT 
PROMPT Predicates in the execution plan
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
create or replace view max_5_weeks_vw as
   select  country , product, region, year, week,sale, 
    max (sale) over(
          partition by product, country, region ,year
          order by year, week
	  rows between 2 preceding and 2 following 
           ) max_weeks_5
  from sales_fact
/

select year, week, sale, max_weeks_5 from  max_5_weeks_vw  
  where country in ('Australia')  and product ='Xtend Memory' and 
  region='Australia' and year= 2000 and week <14
  order by year, week
/

 set lines 120 pages 100
 select * from table (dbms_xplan.display_cursor('','','ALLSTATS LAST'));