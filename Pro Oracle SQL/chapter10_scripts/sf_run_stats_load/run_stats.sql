
-- run_stats.sql
-- query the stats created by test harness
-- from Tom Kyte - asktom.oracle.com/~tkyte/runstats.html
-- see ~/oracle/dba/run_stats for all files

set linesize 80
set pagesize 60
col name format a40

select a.name, b.value-a.value run1, c.value-b.value run2,
	( (c.value-b.value)-(b.value-a.value)) diff
from run_stats a, run_stats b, run_stats c
where a.name = b.name
	and b.name = c.name
	and a.runid = 'before'
	and b.runid = 'after 1'
	and c.runid = 'after 2'
	and (c.value-a.value) > 0
	and (c.value-b.value) <> (b.value-a.value)
order by abs( (c.value-b.value)-(b.value-a.value))
/

