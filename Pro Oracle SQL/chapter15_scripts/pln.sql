SELECT xplan.*
  FROM
     (
    select max(sql_id) keep
           (dense_rank last order by last_active_time) sql_id
         , max(child_number) keep
           (dense_rank last order by last_active_time) child_number
      from v$sql
     where upper(sql_text) like '%&1%'
       and upper(sql_text) not like '%FROM V$SQL WHERE UPPER(SQL_TEXT) LIKE %'
     ) sqlinfo,
    table(DBMS_XPLAN.DISPLAY_CURSOR(sqlinfo.sql_id, sqlinfo.child_number, 'ALLSTATS LAST')) xplan
/

