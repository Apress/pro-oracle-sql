
-- showplan9i.sql
-- works with 9.2+

SET PAUSE OFF
SET VERIFY OFF
set trimspool on
set line 200 arraysize 1
clear break
clear compute


select *
from table(dbms_xplan.display_cursor( null,null,'ALLSTATS LAST'))
/


