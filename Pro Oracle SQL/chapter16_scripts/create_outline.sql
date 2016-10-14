-- Kerry Osborne
--
-- this is here to attempt to avoid the "ORA-03113: end-of-file on communication channel" error
-- (per metalink) to workaround Bug 5454975 fixed 10.2.0.4
alter session set use_stored_outlines=true; 

set serveroutput on
set pagesize 9999
set linesize 155
var hval number
accept sql_id -
       prompt 'Enter value for sql_id: ' 
accept child_number -
       prompt 'Enter value for child_number: ' 
accept o_name -
       prompt 'Enter value for outline_name (OL_sqlid_planhash): ' -
       default 'X0X0X0X0'
accept category -
       prompt 'Enter value for category (DEFAULT): ' -
       default 'DEFAULT'

DECLARE
-- oname varchar2(30) := 'XOXOXOXO';
l_name varchar2(30);
sql_string varchar2(300);
BEGIN

select
hash_value,
decode('&&o_name','X0X0X0X0','OL_&&sql_id'||'_'||plan_hash_value,'&&o_name')
into
:hval, l_name
from
v$sql
where
sql_id = '&&sql_id'
and child_number = &&child_number;

  DBMS_OUTLN.create_outline(
    hash_value    => :hval, 
    child_number  => &&child_number,
    category      => '&&category');

   select 'alter outline '||name||' rename to "'||l_name||'"' into sql_string
   from dba_outlines
   where timestamp = (select max(timestamp) from dba_outlines);
   dbms_output.put_line(' ');

execute immediate sql_string;
dbms_outln.clear_used('&&o_name');
dbms_output.put_line('Outline '||l_name||' created.');

END;
/
undef sql_id
undef child_number
undef o_name
undef category
