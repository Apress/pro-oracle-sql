PROMPT 
PROMPT Model clause with no partition pruning
PROMPT
PROMPT Prerequisite: Listing_9_31_partition.sql
PROMPT
  col product format A30
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
  select * from (
  select product, country, year, week, inventory, sale, receipts
  from sales_fact_part sf
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules automatic order(
       inventory [year, week ] order by year,  week =
                                 nvl(inventory [cv(year),  cv(week)-1 ] ,0)
                                  - sale[cv(year),  cv(week) ] +
                                  + receipts [cv(year), cv(week) ]
   )
 )   where year=2000 and country='Australia' and product='Xtend Memory'
/

select * from table(dbms_xplan.display_cursor('','','ALL'));