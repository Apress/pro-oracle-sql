rem
rem Displays index information
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
     and a.table_name = v_table;

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  INDEX INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if;
end;
/

set verify off feed off numwidth 15 lines 500 heading on
set null .


column INDEX_NAME heading 'Index Name'
column INDEX_TYPE format a8 heading 'Type'
column STATUS format a8 heading 'Status'
column VISIBILITY format a4 heading 'Vis?'
column LAST_ANALYZED heading 'Last Analyzed'
column SAMPLE_SIZE heading 'Sample Size'
column DEGREE format a3 heading 'Deg'
column PARTITIONED format a5 heading 'Part?'
column UNIQUENESS format a5 heading 'Uniq?'
column BLEVEL format 999999 heading 'BLevel'
column LEAF_BLOCKS heading 'Leaf Blks'
column NUM_ROWS heading '# Rows'
column DISTINCT_KEYS heading 'Distinct Keys'
column AVG_LEAF_BLOCKS_PER_KEY heading 'Avg Lf/Blks/Key'
column AVG_DATA_BLOCKS_PER_KEY heading 'Avg Dt/Blks/Key'
column CLUSTERING_FACTOR heading 'Clustering Factor'
	

select INDEX_NAME,  
	BLEVEL, LEAF_BLOCKS, NUM_ROWS, DISTINCT_KEYS,
	AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR,
	SAMPLE_SIZE, case when uniqueness = 'UNIQUE' then 'YES' else 'NO ' end UNIQUENESS,
	substr(INDEX_TYPE,1,4) index_type, STATUS, DEGREE,
	PARTITIONED, 
	null VISIBILITY,
	-- case when visibility = 'VISIBLE' then 'YES' else 'NO ' end VISIBILITY, 
	LAST_ANALYZED
from all_indexes
where table_owner = UPPER('&p_owner')
and table_name = UPPER('&p_table')
order by index_name ;


column column_name format a30 heading 'Column Name'
column index_name heading 'Index Name'
column column_position format 999999999 heading 'Pos#'
column descend format a5 heading 'Order'
column column_expression format a40 heading 'Expression'

break on index_name skip 1


select lower(b.index_name) index_name, b.column_position, b.descend, lower(b.column_name) column_name  
from all_ind_columns b
where b.table_owner = UPPER('&p_owner')
and b.table_name = UPPER('&p_table')
order by b.index_name, b.column_position, b.column_name
/

set head on
clear breaks
