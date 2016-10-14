
-- test_harness.sql
-- from Tom Kyte - asktom.oracle.com/~tkyte/runstats.html
-- see ~/oracle/dba/run_stats for all files

-- delete old stats
-- lock semaphore
-- start children ( share locks on semaphore )
-- get time
-- release semaphore 
-- attempt to relock semaphore
-- get time and stats when lock obtained
-- release lock
-- look at stats
-- do parts of this twice

define child_count = 20

variable l_start number;

select 'RUN_1 Start Time: ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss') RUN_1_START from dual;

lock table semaphore in exclusive mode;

host ./thc1.sh &&child_count
prompt Waiting for children to start
host ./child_wait.sh

var l_end number
var l_elapsed number
var exe_count number

var child_count number

begin
	-- hard code known values for this test
	:exe_count := 20;
	:child_count := &child_count;
end;
/

begin

	delete from run_stats;
	delete from my_sess_events;
	-- start by getting a snapshot of the v$ tables
	insert into run_stats select 'before', allstats.* from allstats;
	--insert into run_stats select 'before', stats.* from stats;
	commit;

	-- immediately lock exit semaphore
	-- ( possible race condition, but not too likely
	--  if tests run at least a second or so )
	lock table exit_semaphore in exclusive mode;

	-- and start timing...
	--:l_start := dbms_utility.get_time;
	:l_start := get_epoch_microseconds;

	-- lock won't succeed until children rollback;
	lock table semaphore in exclusive mode;

	:l_end := get_epoch_microseconds;
	:l_elapsed := :l_end - :l_start;
	dbms_output.put_line( 'MATERIALIZE' );
	dbms_output.put_line( :l_elapsed || ' secs' );
	dbms_output.put_line( 'avg response time: ' || to_char(:l_elapsed / (:exe_count * :child_count), '990.999999'));
   
	insert into run_stats select 'after 1', allstats.* from allstats;

	insert into my_sess_events(id,event,time_waited_micro) 
	select 'RUN_1', se.event, sum(se.time_waited_micro)
	from v$session_event se, v$session sess
	where sess.sid = se.sid
	and sess.module = 'RUN_1'
	group by se.event;

	--insert into run_stats select 'after 1', stats.* from stats;
	commit;
	-- children in thc1.sh will exit at this point

end;
/

select 'RUN_2 Start Time: ' || to_char(sysdate,'mm/dd/yyyy hh24:mi:ss') RUN_2_START from dual;

lock table semaphore in exclusive mode;
host ./thc2.sh &&child_count
prompt Waiting for children to start
host ./child_wait.sh

begin
	-- release lock
	commit;

	-- immediately lock exit semaphore
	lock table exit_semaphore in exclusive mode;

	-- start timing
	--:l_start := dbms_utility.get_time;
	:l_start := get_epoch_microseconds;

	-- lock won't succeed until children rollback;
	lock table semaphore in exclusive mode;

	:l_end := get_epoch_microseconds;
	:l_elapsed := :l_end - :l_start;
	dbms_output.put_line( 'INLINE' );
	dbms_output.put_line( :l_elapsed || ' secs' );
	dbms_output.put_line( 'avg response time: ' || to_char(:l_elapsed / (:exe_count * :child_count), '990.999999'));

	insert into run_stats select 'after 2', allstats.* from allstats;

	insert into my_sess_events(id,event,time_waited_micro) 
	select 'RUN_2', se.event, sum(se.time_waited_micro)
	from v$session_event se, v$session sess
	where sess.sid = se.sid
	and sess.module = 'RUN_2'
	group by se.event;

	--insert into run_stats select 'after 2', stats.* from stats;
	commit;
	-- children in thc2.sh will exit at this point

end;
/


--@run_stats
@insert_results
@sr
@my_sess_events



