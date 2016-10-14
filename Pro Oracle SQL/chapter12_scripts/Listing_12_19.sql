PROMPT 
PROMPT Descending indexes
PROMPT

column index_name format A30

drop index sales_fact_c1;

create index sales_fact_c1 on sales_fact ( product desc, year desc, week desc ) ; 

@analyze_sf.sql

set termout off
select year, week from sales_fact s where year in ( 1998,1999,2000) and week<5
and product='Xtend Memory' 
 order by product desc,year desc, week desc ;
set termout on
@x

select index_name, index_type from dba_indexes
where index_name='SALES_FACT_C1';