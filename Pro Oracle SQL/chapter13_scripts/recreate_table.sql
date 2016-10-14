set timing off
set verify off
accept owner -
 prompt 'Enter value for owner: ' -
 default 'KSO'
accept table_name -
 prompt 'Enter value for table_name: ' -
 default 'SKEW'
col ddl for a120
set heading off
set feedback off
spool recreate_&&table_name\.sql

exec  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'SQLTERMINATOR',true);
exec  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',false);

select 'set echo on' ddl from dual
union
select 'set timing on' ddl from dual;

-- rename original indexes 

select 'ALTER INDEX '||'&&owner'||'.'||index_name||' RENAME TO '||substr(index_name,1,26)||'_OLD;' DDL 
  from dba_indexes
  where table_name like '&&table_name'
  and owner like '&&owner';

-- generate DDL for table, INSERT for data, DDL for indexes, DDL for grants, DDL for triggers

select replace(DDL,'"&&table_name"',substr('"&&table_name',1,25)||'_TEMP"') DDL from (
  select 1, to_char(dbms_metadata.get_ddl('TABLE',nvl(upper('&&table_name'),''),nvl(upper('&&owner'),user))) DDL from dual);

-- generate stub for insert

select '/*' from dual;
select column_name||',' ddl     
  from dba_tab_cols
  where table_name like '&&table_name'
  and owner like '&&owner';
select '*/' from dual;

  select '  INSERT /*+ APPEND */ INTO '||'&&owner'||'.'||substr('&&table_name',1,25)||'_TEMP'||
            ' SELECT /*+ PARALLEL (a 4) */ * FROM '||'&&owner'||'.'||'&&table_name'||' a;' DDL from dual;

-- generate DDL for indexes, DDL for grants, DDL for triggers

select replace(DDL,'"&&table_name"',substr('"&&table_name',1,25)||'_TEMP"') DDL from (
  select 3, to_char(dbms_metadata.get_ddl('INDEX',index_name,upper('&&owner'))) DDL from dba_indexes
        where owner = '&&owner'
        and table_name = '&&table_name'
union
  select 4, (case 
        when ((select count(*)
               from   dba_tab_privs
               where owner = '&&owner'
               and table_name = '&&table_name') > 0)
        then  to_char(dbms_metadata.get_dependent_ddl( 'OBJECT_GRANT', '&&table_name', '&&owner' )) 
        else  '   -- Note: No Grants found!'
        end ) DDL from dual
union
  select 5, (case 
        when ((select count(*)
               from   dba_triggers
               where table_owner = '&&owner'
               and table_name = '&&table_name') > 0)
        then  to_char(dbms_metadata.get_dependent_ddl( 'TRIGGER', '&&table_name', '&&owner' )) 
        else  '   -- Note: No Triggers found!'
        end ) DDL from dual
/*
union
  select 6, to_char(dbms_metadata.get_dependent_ddl( 'REF_CONSTRAINT', '&&table_name', '&&owner' )) DDL from dual
*/
order by 1
);

-- add constraints (NOTE: create table statement will fail because it already exists)

exec  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS',true);
exec  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM,'CONSTRAINTS_AS_ALTER',true);
select replace(DDL,'"&&table_name"',substr('"&&table_name',1,25)||'_TEMP"') DDL from (
  select to_char(dbms_metadata.get_ddl('TABLE',nvl(upper('&&table_name'),''),nvl(upper('&&owner'),user))) DDL from dual);

-- swap tables

select '--  ALTER TABLE '||'&&owner'||'.'||'&&table_name'||
        ' RENAME TO '||substr('&&table_name',1,25)||'_ORIG;' DDL from dual;
select '--  ALTER TABLE '||'&&owner'||'.'||substr('&&table_name',1,25)||'_TEMP'||
      ' RENAME TO '||'&&table_name'||';' DDL from dual;

-- cleanup

select 'set echo off' from dual;
spool off
set head on
set feedback on
set echo off
undef owner
undef table_name
