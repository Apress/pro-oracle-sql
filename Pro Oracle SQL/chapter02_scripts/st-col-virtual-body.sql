rem
rem Displays virtual column expressions
rem


declare
  v_owner varchar2(30) := upper('&p_owner');
  v_table varchar2(30) := upper('&p_table');
  v_ct            number ;

begin

  v_ct := 0;

	select count(1)
	into v_ct
	from all_tab_cols c
	where c.owner = v_owner
	and c.table_name = v_table
	and c.virtual_column = 'YES';

  if v_ct > 0 then
      dbms_output.put_line('');
      dbms_output.put_line('===================================================================================================================================');
      dbms_output.put_line('  VIRTUAL AND HIDDEN COLUMN INFORMATION');
      dbms_output.put_line('===================================================================================================================================');
  end if;
end;
/

set verify off feed off numwidth 15 lines 500 heading on

column column_name heading 'Column Name'
column vc_expression format a50 heading 'Expression'
column qualified_col_name format a50 heading 'Expression'

select c.column_name, 
	(select extension from all_stat_extensions 
	where extension_name = c.column_name 
	and owner = c.owner
	and table_name = c.table_name
	and rownum = 1) vc_expression
from all_tab_cols c
where c.owner = UPPER('&p_owner')
and c.table_name = UPPER('&p_table')
and c.virtual_column = 'YES'
order by c.column_name
/

set head off

select column_name, qualified_col_name
from all_tab_cols
where owner = UPPER('&p_owner')
and table_name = UPPER('&p_table')
and hidden_column = 'YES'
and column_name <> qualified_col_name
order by column_name
/

set head on
