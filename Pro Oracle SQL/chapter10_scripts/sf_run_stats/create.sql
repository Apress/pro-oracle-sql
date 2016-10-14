
@@drop

-- create run_stats table
@ /home/jkstill/oracle/dba/run_stats/table.sql

create table semaphore ( systime date );
create table exit_semaphore ( systime date );

create table results(
	child_count number(6,0) not null,
	name varchar2(80) not null,
	run1 number,
	run2 number,
	diff number
)
/


create table my_sess_events (
	id varchar2(10) not null,
	event varchar2(64) not null,
	time_waited_micro number
)
/



