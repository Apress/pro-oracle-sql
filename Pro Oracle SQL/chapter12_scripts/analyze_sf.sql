 set lines 120 pages 100

begin
   dbms_stats.gather_table_stats (
   ownname =>user,
   tabname=>'SALES_FACT',
   estimate_percent=>30,
   cascade=>true);
end;
/
