
@clears

set line 200
set pagesize 50000

col name format a30 wrap
col child_count format 999 head 'CHILD|COUNT'
col run1 format 99,999,999,999 head 'MATERIALIZE'
col run2 format 99,999,999,999 head 'INLINE'
col diff format 999,999,999,999

--select name, child_count, run1, run2, diff
select name, run1, run2, diff
from results
where abs(decode(least(run1,run2),0,.0001, least(run1,run2)) / greatest(run1,run2) ) < .1
and abs(diff) > 100
order by abs(diff)
/

