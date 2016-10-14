begin
   dbms_stats.restore_table_stats (
      '&Owner',
      '&table_name',
      '&as_of_date'||' 12.00.00.000000000 AM -04:00'); /* Noon */
end;
/
