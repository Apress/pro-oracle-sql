
-- showplan_last.sql

set pause off
set verify off
set trimspool on
set line 200 arraysize 1
clear break
clear compute
-- serveroutput must be OFF for dbms_xplan.display_cursor to work.
-- but do not turn it off here, or the SET statemeent will be the 'last' cursor

select *
from table(dbms_xplan.display_cursor( null,null,'TYPICAL LAST'))
--from table(dbms_xplan.display_cursor( null,null,'ALLSTATS LAST'))
--from table(dbms_xplan.display_cursor( null,null,'ALLSTATS PREDICATE LAST'))
--from table(dbms_xplan.display_cursor( null,null,'ALLSTATS ALIAS PROJECTION PREDICATE LAST'))
--from table(dbms_xplan.display_cursor( null,null,'ADVANCED LAST'))
/


