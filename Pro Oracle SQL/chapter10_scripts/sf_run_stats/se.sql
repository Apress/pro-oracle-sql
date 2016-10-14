   select 'RUN_1', se.event, sum(se.time_waited_micro)
   from v$session_event se, v$session sess
   where sess.sid = se.sid
   and sess.module = 'RUN_1'
   group by se.event
/
