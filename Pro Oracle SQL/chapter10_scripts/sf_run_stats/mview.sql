
-- view.sql
-- run as SYS

@@defaults

create or replace view allstats
as select 'STAT...' || a.name name, value
from v$statname a, v$sysstat b --, v$session c
where a.statistic# = b.statistic#
union all
select 'LATCH.' || name,  gets
from v$latch
union all
select 'EVENT..' || e.event name, sum(time_waited)/100 value
from v$system_event e
group by event
; 

create public synonym allstats for sys.allstats;

grant select on allstats to public;

-- grant to user as well, if needed in a stored proc
grant select on allstats to &&username;


