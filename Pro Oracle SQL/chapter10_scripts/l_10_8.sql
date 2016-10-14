

set linesize 200
set serveroutput off
set timing on

col prod_name format a30 head 'PRODUCT'
col channel_name format a12 head 'CHANNEL'
col avg_cost format 99,999.90 head 'AVG COST'
col min_cost format 99,999.90 head 'MIN COST'
col max_cost format 99,999.90 head 'MAX COST'


break on report
compute sum of avg_cost on report
compute sum of min_cost on report
compute sum of max_cost on report

spool l_10_8.txt

select /*+ gather_plan_statistics */
   substr(prod_name,1,30) prod_name
   , channel_desc
   , (
      select avg(c2.unit_cost)
      from sh.costs c2
      where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
      and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') 
      	and to_date('12/31/2000','mm/dd/yyyy')
      ) avg_cost
   , (
      select min(c2.unit_cost)
      from sh.costs c2
      where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
      and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') 
      	and to_date('12/31/2000','mm/dd/yyyy')
      ) min_cost
   , (
      select max(c2.unit_cost)
      from sh.costs c2
      where c2.prod_id = c.prod_id and c2.channel_id = c.channel_id
      and c2.time_id between to_date('01/01/2000','mm/dd/yyyy') 
      	and to_date('12/31/2000','mm/dd/yyyy')
      ) max_cost
from (
   select distinct pr.prod_id, pr.prod_name, ch.channel_id, ch.channel_desc
   from sh.channels ch
      , sh.products pr
      , sh.costs co
   where ch.channel_id = co.channel_id
      and co.prod_id = pr.prod_id
      and co.time_id between to_date('01/01/2000','mm/dd/yyyy') 
      	and to_date('12/31/2000','mm/dd/yyyy')
) c
order by prod_name, channel_desc

l

/

@showplan_last

spool off


