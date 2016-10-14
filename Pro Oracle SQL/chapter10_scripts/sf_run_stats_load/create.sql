
@@drop

-- create run_stats table
@ ../run_stats/table.sql

create table semaphore ( systime date );
create table exit_semaphore ( systime date );

create table results(
	child_count number(6,0) not null,
	name varchar2(60) not null,
	run1 number,
	run2 number,
	diff number
)
/

