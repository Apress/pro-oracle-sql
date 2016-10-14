rem
rem Displays table partition information
rem


declare
	v_owner varchar2(30) := upper('&p_owner');
	v_table varchar2(30) := upper('&p_table');
	v_ct    number ;


begin
  v_ct := 0 ;

  select count(1)
    into v_ct
    from all_tab_partitions
   where table_owner = UPPER(v_owner)
     and table_name = UPPER(v_table);

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  PARTITION INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if ;
end;
/

set verify off feed off numwidth 15 lines 500 heading on long 300
column PARTITION_POSITION format 99999 heading 'Part#'
column PARTITION_NAME heading 'Partition Name'
column LAST_ANALYZED heading 'Last Analyzed'
column SAMPLE_SIZE heading 'Sample Size'
column NUM_ROWS heading '# Rows'
column BLOCKS heading '# Blocks'
column HIGH_VALUE heading 'Partition Bound'


select PARTITION_POSITION, PARTITION_NAME, SAMPLE_SIZE, 
       NUM_ROWS, BLOCKS, HIGH_VALUE, LAST_ANALYZED
from all_tab_partitions
where table_owner = UPPER('&p_owner')
and table_name = UPPER('&p_table')
order by partition_position;

