
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

spool l_10_9.txt

with bookends as (
   select 
   	to_date('01/01/2000','mm/dd/yyyy') begin_date
      ,to_date('12/31/2000') end_date
   from dual
),
prodmaster as (
   select distinct pr.prod_id, pr.prod_name, ch.channel_id, ch.channel_desc
   from sh.channels ch
      , sh.products pr
      , sh.costs co
   where ch.channel_id = co.channel_id
      and co.prod_id = pr.prod_id
      and co.time_id between (select begin_date from bookends) 
      	and (select end_date from bookends)
),
cost_compare as (
      select
         prod_id
         , channel_id
         , avg(c2.unit_cost) avg_cost
         , min(c2.unit_cost) min_cost
         , max(c2.unit_cost) max_cost
      from sh.costs c2
      where c2.time_id between (select begin_date from bookends) 
      	and (select end_date from bookends)
      group by c2.prod_id, c2.channel_id
)
select /*+ gather_plan_statistics */
   substr(pm.prod_name,1,30) prod_name
   , pm.channel_desc
   , cc.avg_cost
   , cc.min_cost
   , cc.max_cost
from prodmaster pm
join cost_compare cc on cc.prod_id = pm.prod_id
   and cc.channel_id = pm.channel_id
order by pm.prod_name, pm.channel_desc

l

/

@showplan_last

spool off
