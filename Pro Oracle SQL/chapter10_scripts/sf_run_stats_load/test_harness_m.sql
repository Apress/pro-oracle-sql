
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

define child_count = 10

variable l_start number;

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
	:exe_count := 200;
	:child_count := 10;
end;
/

begin

	-- start by getting a snapshot of the v$ tables
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
	dbms_output.put_line( :l_elapsed || ' secs' );
   
	commit;
	-- children in thc1.sh will exit at this point

end;
/

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
	dbms_output.put_line( :l_elapsed || ' secs' );

	commit;
	-- children in thc2.sh will exit at this point

end;
/

--@run_stats

