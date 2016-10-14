set lines 120 pages 100
begin
   dbms_stats.gather_table_stats (
   ownname =>user,
   tabname=>'&tabname',
   estimate_percent=>100,
   cascade=>true);
end;
/
