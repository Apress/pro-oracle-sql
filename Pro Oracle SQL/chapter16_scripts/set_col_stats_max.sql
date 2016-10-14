----------------------------------------------------------------------------------------
--
-- File name:   set_col_stats_max.sql
--
-- Purpose:     Set the max (and maybe min) values for a column.
--
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for five values.
--
--              owner: the owner of the table
--
--              table_name: the name of the table
--
--              column_name: the name of the column
--
--              minimum: the minimum value for this column (default is to leave it alone)
--
--              maximum: the maximum vlalue for this column
--
-- Description: The idea is to use this script to manually set the maximum value for a 
--              column. This is occassionally necessary for large table where the default
--              stats gathering does not kick in often enough (or are too time consuming
--              to generate) to keep the max in the stats inline with reality.  
--
--             (note that this script only works for varchar2's at this point)
--              
--              See kerryosborne.oracle-guy.com for additional information.
---------------------------------------------------------------------------------------
accept owner -
       prompt 'Enter value for owner: ' -
       default 'KSO'
accept table_name -
       prompt 'Enter value for table_name: ' -
       default 'LITTLE_SKEW'
accept column_name -
       prompt 'Enter value for column_name: ' - 
       default 'COL2'
accept minimum -
       prompt 'Enter value for minimum: '  -
      default 'XOXOXOXO'
accept maximum -
       prompt 'Enter value for maximum ' 

DECLARE
  l_statrec dbms_stats.statrec;
  l_charvals dbms_stats.chararray;
  l_bkvals dbms_stats.numarray;
  l_min varchar2(2000);
BEGIN
  NULL;
  l_charvals := dbms_stats.chararray ();
  l_charvals.extend (2);


/*
For Frequency Histogram - this is number of occurences

  l_bkvals := dbms_stats.numarray ();
  l_bkvals.extend (2);
  l_bkvals(1)  := 91;
  l_bkvals(2)  := 51;
  l_statrec.bkvals := l_bkvals;
*/

If '&&minimum' = 'XOXOXOXO' then
  select display_raw(low_value,data_type) into l_min
  from dba_tab_cols
  where owner = '&&owner'
  and table_name = '&&table_name'
  and column_name = '&&column_name';
  l_charvals(1)  := l_min;
else
  l_charvals(1)  := '&&minimum';    
end if;

  l_charvals(2)  := '&&maximum';    

  l_statrec.epc := 2;
  l_statrec.eavs := 0;

  DBMS_STATS.PREPARE_COLUMN_VALUES (l_statrec,l_charvals);

  DBMS_STATS.SET_COLUMN_STATS
  (
    ownname => '&&owner',
    tabname => '&&table_name',
    colname => '&&column_name',
    srec     => l_statrec
  );
END;
/
undef owner
undef table_name
undef column_name
