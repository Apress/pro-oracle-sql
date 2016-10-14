 set lines 120 pages 100
 select * from table (dbms_xplan.display_cursor('','','ALLSTATS LAST'));
