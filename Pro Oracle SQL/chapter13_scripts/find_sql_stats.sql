set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a40
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col execs format 9,999,999
col execs_per_sec format 999,999.99
col etime format 9,999,999.99
col avg_etime format 99,999.99
col cpu format 9,999,999
col avg_cpu  format 99,999.99
col pio format 9,999,999
col avg_pio format 99,999.99
col lio format 9,999,999
col avg_lio format 9,999,999

select sql_id, child_number, plan_hash_value,
executions execs,
rows_processed ,
-- executions/((sysdate-to_date(first_load_time,'YYYY-MM-DD/HH24:MI:SS'))*(24*60*60)) execs_per_sec,
-- elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime,
-- cpu_time/1000000 cpu,
(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_cpu,
-- disk_reads pio,
disk_reads/decode(nvl(executions,0),0,1,executions) avg_pio,
-- buffer_gets lio,
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from v$sql s
where sql_text like nvl('&sql_text',sql_text)
and sql_text not like '%from v$sql where sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
order by sql_id, child_number
/

