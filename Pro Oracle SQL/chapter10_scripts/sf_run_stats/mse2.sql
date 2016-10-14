select
	av.event
	, nvl(r1.time_waited_seconds,0) time_waited_seconds_1
	, nvl(r2.time_waited_seconds,0) time_waited_seconds_2
	, nvl(r1.time_waited_seconds,0) - nvl(r2.time_waited_seconds,0) time_diff
from
(
	select distinct event
	from my_sess_events
) av
left outer join 
(
	select s.id, s.event, s.time_waited_micro/1000000 time_waited_seconds
	from my_sess_events s
	where s.id = 'RUN_1'
) r1 on r1.event = av.event
left outer join (
	select s.id, s.event, s.time_waited_micro/1000000 time_waited_seconds
	from my_sess_events s
	where s.id = 'RUN_2'
) r2 on r2.event = av.event
order by event
/
