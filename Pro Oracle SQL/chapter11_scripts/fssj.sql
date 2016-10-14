break on sql_id on child_number on plan_hash on execs on avg_etime on avg_lio on avg_rows on sql_text
col sql_text for a60 wrap
set verify off
set pagesize 999
set lines 165
col username format a13
col prog format a22
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col avg_pio format 9,999,999.99
col avg_lio format 999,999,999
col etime format 9,999,999.99
col join for a20

select distinct s.sql_id, s.child_number, s.plan_hash_value plan_hash, executions execs, 
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, 
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
(rows_processed)/decode(nvl(executions,0),0,1,executions) avg_rows, 
sql_text, 
-- decode(options,'SEMI',operation||' '||options,null) join
case when options like '%SEMI%' then operation||' '||options end join
from v$sql s, v$sql_plan p
where s.sql_id = p.sql_id
and s.child_number = p.child_number
and upper(sql_text) like upper(nvl('&sql_text','%department%'))
and sql_text not like '%from v$sql where sql_text like nvl(%'
and s.sql_id like nvl('&sql_id',s.sql_id)
order by 1, 2, 3
/
