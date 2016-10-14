

col value format 999,999,999,999

select runid, name, value
from run_stats a, run_stats b, run_stats c
where a.name = 'LATCH.cache buffers chains'
and b.name = 'LATCH.cache buffers chains'
and c.name = 'LATCH.cache buffers chains'
/
