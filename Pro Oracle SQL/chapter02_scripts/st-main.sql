rem
rem Main caller for retrieving statistics information by owner/table
rem

set echo off feed off

set serveroutput on for wra

exec dbms_output.enable(1000000);

alter session set nls_date_format = 'mm/dd/yyyy hh24:mi:ss';

set termout on
accept p_own prompt 'Enter the owner name: '
accept p_tab prompt 'Enter the table name: '

define p_owner = '&p_own'
define p_table = '&p_tab'

set termout on lines 500
