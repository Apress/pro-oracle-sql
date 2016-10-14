
col id format a10
col event format a30
col time_waited_seconds_1 format 99999.90 head 'RUN 1|TIME|WAITED|SECONDS'
col time_waited_seconds_2 format 99999.90 head 'RUN 2|TIME|WAITED|SECONDS'
col time_diff format 99999.90 head 'TIME|DIFF'

break on report

compute sum of time_waited_seconds_1 on report
compute sum of time_waited_seconds_2 on report
compute sum of time_diff on report

with all_events as (
	select distinct event
	from my_sess_events
),
r1_events as (
	select s.id, s.event, s.time_waited_micro/1000000 time_waited_seconds
	from my_sess_events s
	where s.id = 'RUN_1'
),
r2_events as (
	select s.id, s.event, s.time_waited_micro/1000000 time_waited_seconds
	from my_sess_events s
	where s.id = 'RUN_2'
)
select 
	av.event
	, nvl(r1.time_waited_seconds,0) time_waited_seconds_1
	, nvl(r2.time_waited_seconds,0) time_waited_seconds_2
	, nvl(r1.time_waited_seconds,0) - nvl(r2.time_waited_seconds,0) time_diff
from all_events av
left outer join r1_events r1 on r1.event = av.event
left outer join r2_events r2 on r2.event = av.event
order by event
/
