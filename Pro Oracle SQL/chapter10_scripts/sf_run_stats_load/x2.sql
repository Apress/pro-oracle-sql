
col runid format a10
col name format a30
col value format 999,999,999,999

select runid, name, value
from run_stats
where name = 'LATCH.cache buffers chains'
/
