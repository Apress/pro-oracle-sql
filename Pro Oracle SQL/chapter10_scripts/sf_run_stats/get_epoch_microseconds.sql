
-- get_epoch_microsends.sql

-- return the time as the number of seconds since 1970
-- plus the microseconds of the current second
-- requires oracle 9i

create or replace function get_epoch_microseconds return number
is
	v_date date;
	v_epoch_secs number default 0;
	v_day_secs number default 0;
	v_hour_secs number default 0;
	v_10k_secs number(8,6) default 0;
	v_total_secs number(22,6) default 0;
begin
	
	v_date := sysdate;

	v_epoch_secs	:= 86400*(trunc(v_date) - to_date('1970','yyyy'));
	v_day_secs		:= 86400*(trunc(v_date,'hh24') - trunc(v_date));
	v_hour_secs		:= 86400*(trunc(v_date,'mi') - trunc(v_date,'hh24'));

	v_10k_secs := to_number(to_char(systimestamp, 'ss.ff6')) ; 

	v_total_secs := v_epoch_secs + v_day_secs + v_hour_secs + v_10k_secs;

	return v_total_secs;

end;
/

show errors function get_epoch_microseconds

col get_epoch_microseconds format 9999999999.999999

select get_epoch_microseconds from dual;


