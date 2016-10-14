set verify off
set pagesize 999
set lines 165
col table_name format a25 trunc
col column_name format a25
col avg_len format 9999999
col NDV format 999,999,999
col buckets format 999999
col low_value format a15
col high_value format a15
col density for .999999999
col data_type for a10
select column_name, data_type, avg_col_len, density, num_distinct NDV, histogram, num_buckets buckets, sample_size, last_analyzed, 
display_raw(low_value,data_type) low_value, display_raw(high_value,data_type) high_value
from dba_tab_cols 
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
and column_name like nvl('%&column_name%',column_name)
order by internal_column_id
/
