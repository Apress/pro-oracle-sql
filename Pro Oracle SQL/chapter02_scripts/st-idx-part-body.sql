rem
rem Displays partitioned index information
rem


declare
  v_owner varchar2(30) := upper('&p_owner');
  v_table varchar2(30) := upper('&p_table');
  v_ct            number ;

begin

  v_ct := 0;

  select count(1)
    into v_ct
    from all_indexes a
   where a.table_owner = v_owner
     and a.table_name = v_table
     and a.partitioned = 'YES';

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  PARTITIONED INDEX INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if;
end;
/

set verify off feed off numwidth 15 lines 500 heading on long 200

column INDEX_NAME heading 'Index Name'
column INDEX_TYPE format a8 heading 'Type'
column STATUS format a8 heading 'Status'
column VISIBILITY format a4 heading 'Vis?'
column LAST_ANALYZED heading 'Last Analyzed'
column DEGREE format a3 heading 'Deg'
column PARTITIONED format a5 heading 'Part?'

column BLEVEL heading 'BLevel'
column LEAF_BLOCKS heading 'Leaf Blks'
column NUM_ROWS heading '# Rows'
column DISTINCT_KEYS heading 'Distinct Keys'
column AVG_LEAF_BLOCKS_PER_KEY heading 'Avg Lf/Blks/Key'
column AVG_DATA_BLOCKS_PER_KEY heading 'Avg Dt/Blks/Key'
column CLUSTERING_FACTOR heading 'Clustering Factor'

column PARTITION_POSITION format 99999 heading 'Part#'
column PARTITION_NAME heading 'Partition Name'
column HIGH_VALUE format a120 tru heading 'Partition Bound'

break on index_name skip 1

select index_name, partition_position, partition_name, BLEVEL, LEAF_BLOCKS, NUM_ROWS, DISTINCT_KEYS,
	AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR,
	STATUS, LAST_ANALYZED, high_value
from all_ind_partitions
where index_owner = UPPER('&p_owner')
and index_name in 
(
select index_name
from all_indexes
where table_owner = UPPER('&p_owner')
and table_name = UPPER('&p_table')
and partitioned = 'YES'
)
order by index_name, partition_position
/

clear breaks
