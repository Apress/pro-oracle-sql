--------------------------------------------------------------------------------
--
-- File name:   snapper.sql
-- Purpose:     An easy to use Oracle session-level performance snapshot utility
--
--              NB! This script does NOT require creation of any database objects!
--
--              This is very useful for ad-hoc performance diagnosis in environments
--              with restrictive change management processes, where creating
--              even temporary tables and PL/SQL packages is not allowed or would
--              take too much time to get approved.
--
--              All processing is done by few sqlplus commands and an anonymous
--              PL/SQL block, all that's needed is SQLPLUS access (and if you want
--              to output data to server-side tracefile then execute rights on
--              DBMS_SYSTEM).
--
--              The output is formatted the way it could be easily post-processed
--              by either Unix string manipulation tools or loaded to spreadsheet.
--
--
-- Author:      Tanel Poder
-- Copyright:   (c) E2SN - http://tech.e2sn.com - All rights reserved.
--
--
-- Thanks to:   Adrian Billington and Jamey Johnston for sending some useful fixes
--
--------------------------------------------------------------------------------
--
--   The Session Snapper v3.11
--   (c) Tanel Poder ( http://tech.e2sn.com )
--
--
--    +-----=====O=== Welcome to The Session Snapper! (Yes, you are looking at a cheap ASCII
--   /                                                 imitation of a fish and a fishing rod.
--   |                                                 Nevertheless the PL/SQL code below the
--   |                                                 fish itself should be helpful for quick
--   |                                                 catching of relevant Oracle performance
--   |                                                 information.
--   |                                                 So I wish you happy... um... snapping?
--   |                                                )
--   |                       ......
--   |                       iittii,,....
--   �                    iiffffjjjjtttt,,
--                ..;;ttffLLLLffLLLLLLffjjtt;;..
--            ..ttLLGGGGGGLLffLLLLLLLLLLLLLLffjjii,,                        ..ii,,
--            ffGGffLLLLLLjjttjjjjjjjjffLLLLLLLLLLjjii..                ..iijj;;....
--          ffGGLLiittjjttttttiittttttttttffLLLLLLGGffii..            ;;LLLLii;;;;..
--        ffEEGGffiittiittttttttttiiiiiiiittjjjjffLLGGLLii..      iiLLLLLLttiiii,,
--      ;;ffDDLLiiiitt,,ttttttttttttiiiiiiiijjjjjjffLLLLffttiiiiffLLGGLLjjtttt;;..
--    ..ttttjjiitt,,iiiiiittttttttjjjjttttttttjjjjttttjjttttjjjjffLLDDGGLLttii..
--    iittiitttt,   ;;iittttttttjjjjjjjjjjttjjjjjjffffffjjjjjjjjjjLLDDGGLLtt;;..
--    jjjjttttii:. ..iiiiffLLGGLLLLLLLLffffffLLLLLLLLLLLLLLLLffffffLLLLLLfftt,,
--    iittttii,,;;,,ttiiiiLLLLffffffjjffffLLLLLLLLffLLffjjttttttttttjjjjffjjii..
--    ,,iiiiiiiiiittttttiiiiiiiiiijjffffLLLLLLLLffLLffttttttii;;;;iiiitttttttt;;..
--    ..iittttttffffttttiiiiiiiiiittttffjjjjffffffffttiittii::    ....,,;;iittii;;
--      ..;;iittttttttttttttttiiiiiittttttttttjjjjjjtttttt;;              ..;;ii;;..
--          ..;;;;iittttttjjttiittttttttttttttjjttttttttii..                  ....
--                ....;;;;ttjjttttiiiiii;;;;;;iittttiiii..
--                      ..;;ttttii;;....      ..;;;;....
--                        ..iiii;;..
--                          ..;;,,
--                            ....
--
--
--  Usage:
--
--      snapper.sql <ash[1-3]|stats|all>[,out][,trace][,pagesize=X][,gather=[s][t][w][l][e][b][a]]> <seconds_in_snap> <snapshot_count> <sid(s)_to_snap>
--
--          ash      - sample session activity ASH style, waits and SQL_IDs from v$session and
--                     print a TOP SQL/wait report from these samples (this is the default from
--                     Snapper 3.0). The columns chosen for TOP calculation are defined in CONFIG
--                     section below.
--
--          ash=sql_id+event+wait_class
--                   - the above example illustrates that you can also specify the v$session
--                     columns for TOP report yourself. The above example will show a TOP
--                     activity report grouped by SQL_ID + EVENT + WAIT_CLASS
--                     Note that the columns are separated by + (as comma is a snapper parameter
--                     separator, not column separator)
--
--          ash1
--          ash2
--          ash3     - in addition to "ash" report you can have 3 more reported during the same
--                     snapper sampling snapshot. Just include ash1=col1+col2,ash2=col3+col4,...
--                     parameters if you want multiple TOP reports per Snapper snapshot
--
--          stats    - sample v$sesstat,v$sess_time_model,v$session_event performance counters
--                     and report how much these stats increased (deltas) during Snapper run
--          all      - report both ASH and stats sections
--
--          out      - use dbms_output.put_line() for output. output will be seen only when
--                     Snapper run completes due dbms_output limitations. This is the default.
--          trace    - write output to server process tracefile
--                     (you must have execute permission on sys.dbms_system.ksdwrt() for that,
--                      you can use both out and trace parameters together if you like )
--
--          pagesize - display header lines after X snapshots. if pagesize=0 don't display
--                     any headers. pagesize=-1 will display a terse header only once
--
--          gather   - if omitted, gathers s,t,w statistics (see below)
--                   - if specified, then gather following:
--
--                        Session-level stats:
--                          s - Session Statistics from v$sesstat
--                          t - Session Time model info from v$sess_time_model
--                          w - Session Wait statistics from v$session_event and v$session_wait
--
--                        Instance-level stats:
--                          l - instance Latch get statistics ( gets + immediate_gets )
--                          e - instance Enqueue lock get statistics
--                          b - buffer get Where statistics -- useful in versions up to 10.2.x
--                          a - All above
--
--          sinclude - if specified, then show only V$SESSTAT stats which match the
--                     LIKE pattern of sinclude (REGEXP_LIKE in 10g+)
--          linclude - if specified, then show only V$LATCH latch stats which match the
--                     LIKE pattern of linclude (REGEXP_LIKE in 10g+)
--          tinclude - if specified, then show only V$SESS_TIME_MODEL stats which match the
--                     LIKE pattern of tinclude (REGEXP_LIKE in 10g+)
--          winclude - if specified, then show only V$SESSION_EVENT wait stats which match the
--                     LIKE pattern of winclude (REGEXP_LIKE in 10g+)
--
--          you can combine above parameters in any order, separate them by commas
--          !!!don't use spaces as otherwise they are treated as next parameters by sqlplus   !!!
--          !!!if you want to use spaces, enclose the whole sqlplus parameter in doublequotes !!!
--
--      <seconds_in_snap> - the number of seconds between taking snapshots
--      <snapshot_count>  - the number of snapshots to take ( maximum value is power(2,31)-1 )
--
--      <sids_to_snap> can be either one sessionid, multiple sessionids separated by
--      commas or a SQL statement which returns a list of SIDs (if you need spaces
--      in that parameter text, enclose it in double quotes).
--
--      if you want to snap ALL sids, use "all" as value for
--      <sids_to_snap> parameter
--
--      alternatively you can used "select sid from v$session" as value for <sids_to_snap>
--      parameter to capture all SIDs. you can write any query (with multiple and/or)
--      conditions to specify complex rules for capturing only the SIDs you want
--
--      starting from version 3.0 there are further session_id selection options available in 
--      instead of sid you can write such expressions for snapper's <sids_to_snap> parameter:
--
--         sid=123     -- take sid 123 only (the same as just writing 123)
--         user=tanel  -- take all sessions where username is 'tanel' (case insensitive)
--                     -- this is the same as writing following subquery for the 
--                     -- <sids_to_snap> parameter:
--                            select sid from v$session where lower(username) like lower('tanel')
--                     
--         user=tanel% -- take all sessions where username begins with 'tanel%' (case insensitive)
--                     -- the = means actually LIKE in SQL terms in this script
-- 
--          spid=1234  -- all these 3 parameters do the same thing:
--          ospid=1234 -- they look up the sessions(s) where the processes OS PID=1234
--          pid=1234   -- this is useful for quickly looking up what some OS process is doing
--                     -- if it consumes too much of some resource
--
--         program=sqlplus%     -- the following examples filter by corresponding v$session coulmns 
--         machine=linux01      -- machine
--         osuser=oracle        -- os username
--         module=HR            -- module
--         "action=Find Order"  -- note the quotes because there is a space inside the parameter
--                              -- value
--         client_id=tanelpoder -- show only sessions where client_identifier is set to tanelpoder
--                              -- this is very useful in cases with (properly instrumented)
--                              -- connection pools
--
--
--      Note that if you want to change some "advanced" snapper configuration parameters
--      or default values then search for CONFIG in this file to see configurable
--      variable section
--
--
--  Examples:
--      NB! Read the online examples, these are more detailed and list script output too!
--
--          http://tech.e2sn.com/oracle-scripts-and-tools/session-snapper
--
--      @snapper ash,stats 1 1 515
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       Wait, v$sesstat and v$sess_time_model statistics are reported by default
--       Starting from V3 the ASH style session activity report is shown as well)
--
--      @snapper stats,gather=w 1 1 515
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       only Wait event statistics are reported, no ASH)
--
--      @snapper ash,gather=st 1 1 515
--      (Output one 1-second snapshot of session 515 using dbms_output and exit
--       only v$sesstat and v$sess_Time_model statistics are gathered + ASH)
--
--      @snapper trace,ash,gather=stw,pagesize=0 10 90 117,210,313
--      (Write 90 10-second snapshots into tracefile for session IDs 117,210,313
--       all statistics are reported, do not print any headers)
--
--      @snapper trace,ash 900 999999999 "select sid from v$session"
--      (Take a snapshot of ALL sessions every 15 minutes and write the output to trace,
--       loop (almost) forever )
--
--      @snapper out,trace 300 12 "select sid from v$session where username='APPS'"
--      (Take 12 5-minute snapshots of all sessions belonging to APPS user, write
--       output to both dbms_output and tracefile)
--
--  Notes:
--
--      Snapper does not currently detect if a session with given SID has
--      ended and been recreated between snapshots, thus it may report bogus
--      statistics for such sessions. The check and warning for that will be
--      implemented in a future version.
--
--------------------------------------------------------------------------------

set termout off tab off verify off linesize 299


-- Get parameters
define snapper_options="&1"
define   snapper_sleep="&2"
define   snapper_count="&3"
define     snapper_sid="&4"


-- The following code is required for making this script "dynamic" as due
-- different Oracle versions, script parameters or granted privileges some
-- statements might not compile if not adjusted properly.

define _IF_ORA10_OR_HIGHER="--"
define _IF_ORA11_OR_HIGHER="--"
define _IF_LOWER_THAN_ORA11="--"
define _IF_DBMS_SYSTEM_ACCESSIBLE="/* dbms_system is not accessible" /*dummy*/
define _IF_X_ACCESSIBLE="--"

define _YES_PLSQL_OBJ_ID="--"  -- plsql_object_id columns available in v$session (from 10.2.0.3)
define _NO_PLSQL_OBJ_ID=""
define _YES_BLK_INST="--"      -- blocking_instance available in v$session (from 10.2)
define _NO_BLK_INST=""


col snapper_ora9           noprint new_value _IF_ORA9
col snapper_ora10higher    noprint new_value _IF_ORA10_OR_HIGHER
col snapper_ora11higher    noprint new_value _IF_ORA11_OR_HIGHER
col snapper_ora11lower     noprint new_value _IF_LOWER_THAN_ORA11
col dbms_system_accessible noprint new_value _IF_DBMS_SYSTEM_ACCESSIBLE
col x_accessible           noprint new_value _IF_X_ACCESSIBLE
col no_plsql_obj_id        noprint new_value _NO_PLSQL_OBJ_ID
col yes_plsql_obj_id       noprint new_value _YES_PLSQL_OBJ_ID
col no_blk_inst            noprint new_value _NO_BLK_INST
col yes_blk_inst           noprint new_value _YES_BLK_INST

col snapper_sid            noprint new_value snapper_sid

-- this block determines whether dbms_system.ksdwrt is accessible to us
-- dbms_describe is required as all_procedures/all_objects may show this object
-- even if its not executable by us (thanks to o7_dictionary_accessibility=false)

var v    varchar2(100)
var x    varchar2(10)

declare

    o       sys.dbms_describe.number_table;
    p       sys.dbms_describe.number_table;
    l       sys.dbms_describe.number_table;
    a       sys.dbms_describe.varchar2_table;
    dty     sys.dbms_describe.number_table;
    def     sys.dbms_describe.number_table;
    inout   sys.dbms_describe.number_table;
    len     sys.dbms_describe.number_table;
    prec    sys.dbms_describe.number_table;
    scal    sys.dbms_describe.number_table;
    rad     sys.dbms_describe.number_table;
    spa     sys.dbms_describe.number_table;

    tmp     number;

begin

    begin
        execute immediate 'select count(*) from x$kcbwh where rownum = 1' into tmp;
        :x:= ' '; -- x$ tables are accessible, so dont comment any lines out
    exception
        when others then null;
    end;

    sys.dbms_describe.describe_procedure(
        'DBMS_SYSTEM.KSDWRT', null, null,
        o, p, l, a, dty, def, inout, len, prec, scal, rad, spa
    );

    -- we never get to following statement if dbms_system is not accessible
    -- as sys.dbms_describe will raise an exception
    :v:= '-- dbms_system is accessible';

exception
    when others then null;
end;
/

-- this is here for a reason
-- im extracting the first word of the snapper_sid (if its a complex expression, not just a single SID)
-- by relying on how DEF and & assignment treat spaces in strings
def ssid_begin=&snapper_sid

select * from (
    select
        case 
            when trim(lower('&ssid_begin')) like 'sid=%' then trim(replace('&ssid_begin','sid=','')) 
            when trim(lower('&ssid_begin')) like 'user=%' then 'select sid from v$session where lower(username) like '''||lower(trim(replace('&ssid_begin','user=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'username=%' then 'select sid from v$session where lower(username) like '''||lower(trim(replace('&ssid_begin','username=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'machine=%' then 'select sid from v$session where lower(machine) like '''||lower(trim(replace('&ssid_begin','machine=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'program=%' then 'select sid from v$session where lower(program) like '''||lower(trim(replace('&ssid_begin','program=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'service=%' then 'select sid from v$session where lower(service_name) like '''||lower(trim(replace('&ssid_begin','service=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'module=%' then 'select sid from v$session where lower(module) like '''||lower(trim(replace('&ssid_begin','module=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'action=%' then 'select sid from v$session where lower(action) like '''||lower(trim(replace('&ssid_begin','action=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'osuser=%' then 'select sid from v$session where lower(osuser) like '''||lower(trim(replace('&ssid_begin','osuser=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'client_id=%' then 'select sid from v$session where lower(client_identifier) like '''||lower(trim(replace('&ssid_begin','client_id=','')))||'''' 
            when trim(lower('&ssid_begin')) like 'spid=%' then 'select sid from v$session where paddr in (select addr from v$process where spid in ('||lower(trim(replace('&ssid_begin','spid=','')))||'))' 
            when trim(lower('&ssid_begin')) like 'ospid=%' then 'select sid from v$session where paddr in (select addr from v$process where spid in ('||lower(trim(replace('&ssid_begin','ospid=','')))||'))' 
            when trim(lower('&ssid_begin')) like 'pid=%' then 'select sid from v$session where paddr in (select addr from v$process where spid in ('||lower(trim(replace('&ssid_begin','pid=','')))||'))' 
            when trim(lower('&ssid_begin')) = 'all' then 'select sid from v$session'
            when trim(lower('&ssid_begin')) = 'bg' then 'select sid from v$session where type=''BACKGROUND'''
            when trim(lower('&ssid_begin')) = 'fg' then 'select sid from v$session where type=''USER'''
            when trim(lower('&ssid_begin')) = 'lgwr' then 'select sid from v$session where program like ''%(LGWR)%'''
            when trim(lower('&ssid_begin')) = 'dbwr' then 'select sid from v$session where program like ''%(DBW%)%'''
            when trim(lower('&ssid_begin')) like 'select%' then null
            when trim(lower('&ssid_begin')) like 'with%'   then null 
            else null
        end snapper_sid -- put the result back to snapper_sid sqlplus value (if its not null)
    from 
        dual
)
where
    snapper_sid is not null -- snapper_sid sqlplus variable value will not be replaced if this query doesnt return any rows
/


-- this query populates some sqlplus variables required for dynamic compilation used below

with mod_banner as (
    select
        replace(banner,'9.','09.') banner
    from
        v$version
    where rownum = 1
)
select
    decode(substr(banner, instr(banner, 'Release ')+8,2), '09', '',  '--') snapper_ora9,
    decode(substr(banner, instr(banner, 'Release ')+8,1), '1',  '',  '--')  snapper_ora10higher,
    decode(substr(banner, instr(banner, 'Release ')+8,2), '11', '',  '--')  snapper_ora11higher,
    decode(substr(banner, instr(banner, 'Release ')+8,2), '11', '--',  '')  snapper_ora11lower,
    nvl(:v, '/* dbms_system is not accessible') dbms_system_accessible,
    nvl(:x, '--') x_accessible,
    case when substr( banner, instr(banner, 'Release ')+8, instr(substr(banner,instr(banner,'Release ')+8),' ') ) >= '10.2'     then ''   else '--' end yes_blk_inst,
    case when substr( banner, instr(banner, 'Release ')+8, instr(substr(banner,instr(banner,'Release ')+8),' ') ) >= '10.2'     then '--' else ''   end no_blk_inst,
    case when substr( banner, instr(banner, 'Release ')+8, instr(substr(banner,instr(banner,'Release ')+8),' ') ) >= '10.2.0.3' then ''   else '--' end yes_plsql_obj_id,
    case when substr( banner, instr(banner, 'Release ')+8, instr(substr(banner,instr(banner,'Release ')+8),' ') ) >= '10.2.0.3' then '--' else ''   end no_plsql_obj_id
from
    mod_banner
/

set termout on serverout on size 1000000 format wrapped

prompt Sampling with interval &snapper_sleep seconds, &snapper_count times...

-- main()
-- let the Snapping start!!!
declare

    -- forward declarations
    procedure output(p_txt in varchar2);
    procedure fout;

    function tptformat( p_num in number,
                        p_stype in varchar2 default 'STAT',
                        p_precision in number default 2,
                        p_base in number default 10,
                        p_grouplen in number default 3
                   )
                   return varchar2;
    function getopt( p_parvalues in varchar2,
                     p_extract in varchar2,
                     p_delim in varchar2 default ','
                   )
                   return varchar2;

    -- type, constant, variable declarations

    -- trick for holding 32bit UNSIGNED event and stat_ids in 32bit SIGNED PLS_INTEGER
    pls_adjust constant number(10,0) := power(2,31) - 1;

    type srec is record (stype varchar2(4), sid number, statistic# number, value number );
    type stab is table of srec index by pls_integer;
    s1 stab;
    s2 stab;

    type snrec is record (stype varchar2(4), statistic# number, name varchar2(64));
    type sntab is table of snrec index by pls_integer;
    sn_tmp sntab;
    sn sntab;

    type sestab is table of v$session%rowtype index by pls_integer;

    g_sessions           sestab;
    g_empty_sessions     sestab;

    type hc_tab is table of number index by pls_integer; -- index is sql hash value
    type ses_hash_tab is table of hc_tab index by pls_integer; -- index is SID
    
    g_ses_hash_tab       ses_hash_tab;
    g_empty_ses_hash_tab ses_hash_tab;

    -- dbms_debug_vc2coll is a built-in collection present in every oracle db
    g_ash                sys.dbms_debug_vc2coll := new sys.dbms_debug_vc2coll();
    g_empty_ash          sys.dbms_debug_vc2coll := new sys.dbms_debug_vc2coll();

    g_ash_samples_taken  number := 0;

    g_count_statname  number;
    g_count_eventname number;

    g_mysid           number;

    i number;
    a number;
    b number;

    c number;
    delta number;
    changed_values number;
    pagesize number:=99999999999999;
    missing_values_s1 number := 0;
    missing_values_s2 number := 0;
    disappeared_sid   number := 0;
    d1 date;
    d2 date;
    ash_date1 date;
    ash_date2 date;
    lv_gather        varchar2(1000);
    gv_header_string varchar2(1000);
    lv_data_string   varchar2(1000);

    lv_ash           varchar2(1000);
    lv_stats         varchar2(1000);

    gather_stats     number := 0;
    gather_ash       number := 0;


    -- CONFIGURABLE STUFF --

        -- this sets what are the default ash sample TOP reporting group by columns
        g_ash_columns     varchar2(1000) := 'sql_id + event + wait_class';
        g_ash_columns1    varchar2(1000) := 'event + wait_class';
        g_ash_columns2    varchar2(1000) := 'sid + sql_id';
        g_ash_columns3    varchar2(1000) := 'plsql_object_id + plsql_subprogram_id + sql_id';

        -- output column configuration
        output_header   number := 0; -- 1=true 0=false
        output_username number := 1; -- v$session.username
        output_sid      number := 1; -- sid
        output_time     number := 0; -- time of snapshot start
        output_seconds  number := 0; -- seconds in snapshot (shown in footer of each snapshot too)
        output_stype    number := 1; -- statistic type (WAIT,STAT,TIME,ENQG,LATG,...)
        output_sname    number := 1; -- statistic name
        output_delta    number := 1; -- raw delta
        output_delta_s  number := 0; -- raw delta normalized to per second
        output_hdelta   number := 0; -- human readable delta
        output_hdelta_s number := 1; -- human readable delta normalized to per second
        output_percent  number := 1; -- percent of total time/samples
        output_pcthist  number := 1; -- percent of total visual bar (histogram)

        -- column widths in ASH report output
        w_sid                         number :=  6;
        w_username                    number := 20;
        w_machine                     number := 20;
        w_terminal                    number := 20;
        w_program                     number := 25;
        w_event                       number := 25;
        w_wait_class                  number := 15;
        w_state                       number :=  8;
        w_p1                          number := 16;
        w_p2                          number := 16;
        w_p3                          number := 16;
        w_row_wait_obj#               number := 10;
        w_row_wait_file#              number :=  6;
        w_row_wait_block#             number := 10;
        w_row_wait_row#               number :=  6;
        w_blocking_session_status     number := 15;
        w_blocking_instance           number := 12;
        w_blocking_session            number := 12;
        w_sql_hash_value              number := 12;
        w_sql_id                      number := 15;
        w_sql_child_number            number := 10;
        w_plsql_entry_object_id       number := 10;
        w_plsql_entry_subprogram_id   number := 10;
        w_plsql_object_id             number := 10;
        w_plsql_subprogram_id         number := 10;
        w_module                      number := 25;
        w_action                      number := 25;
        w_client_identifier           number := 25;
        w_service_name                number := 25;

        w_activity_pct                number :=  7;

    -- END CONFIGURABLE STUFF --

    -- constants for ash collection extraction from the vc2 collection
    s_sid                          constant number := 1 ;
    s_username                     constant number := 2 ;
    s_machine                      constant number := 3 ;
    s_terminal                     constant number := 4 ;
    s_program                      constant number := 5 ;
    s_event                        constant number := 6 ;
    s_wait_class                   constant number := 7 ;
    s_state                        constant number := 8 ;
    s_p1                           constant number := 9 ;
    s_p2                           constant number := 10 ;
    s_p3                           constant number := 11 ;
    s_row_wait_obj#                constant number := 12 ;
    s_row_wait_file#               constant number := 13 ;
    s_row_wait_block#              constant number := 14 ;
    s_row_wait_row#                constant number := 15 ;
    s_blocking_session_status      constant number := 16 ;
    s_blocking_instance            constant number := 17 ;
    s_blocking_session             constant number := 18 ;
    s_sql_hash_value               constant number := 19 ;
    s_sql_id                       constant number := 20 ;
    s_sql_child_number             constant number := 21 ;
    s_plsql_entry_object_id        constant number := 22 ;
    s_plsql_entry_subprogram_id    constant number := 23 ;
    s_plsql_object_id              constant number := 24 ;
    s_plsql_subprogram_id          constant number := 25 ;
    s_module                       constant number := 26 ;
    s_action                       constant number := 27 ;
    s_client_identifier            constant number := 28 ;
    s_service_name                 constant number := 29 ;

    -- constants for ash collection reporting, which columns to show in report
    c_sid                          constant number := power(2, s_sid                      );
    c_username                     constant number := power(2, s_username                 );
    c_machine                      constant number := power(2, s_machine                  );
    c_terminal                     constant number := power(2, s_terminal                 );
    c_program                      constant number := power(2, s_program                  );
    c_event                        constant number := power(2, s_event                    );
    c_wait_class                   constant number := power(2, s_wait_class               );
    c_state                        constant number := power(2, s_state                    );
    c_p1                           constant number := power(2, s_p1                       );
    c_p2                           constant number := power(2, s_p2                       );
    c_p3                           constant number := power(2, s_p3                       );
    c_row_wait_obj#                constant number := power(2, s_row_wait_obj#            );
    c_row_wait_file#               constant number := power(2, s_row_wait_file#           );
    c_row_wait_block#              constant number := power(2, s_row_wait_block#          );
    c_row_wait_row#                constant number := power(2, s_row_wait_row#            );
    c_blocking_session_status      constant number := power(2, s_blocking_session_status  );
    c_blocking_instance            constant number := power(2, s_blocking_instance        );
    c_blocking_session             constant number := power(2, s_blocking_session         );
    c_sql_hash_value               constant number := power(2, s_sql_hash_value           );
    c_sql_id                       constant number := power(2, s_sql_id                   );
    c_sql_child_number             constant number := power(2, s_sql_child_number         );
    c_plsql_entry_object_id        constant number := power(2, s_plsql_entry_object_id    );
    c_plsql_entry_subprogram_id    constant number := power(2, s_plsql_entry_subprogram_id);
    c_plsql_object_id              constant number := power(2, s_plsql_object_id          );
    c_plsql_subprogram_id          constant number := power(2, s_plsql_subprogram_id      );
    c_module                       constant number := power(2, s_module                   );
    c_action                       constant number := power(2, s_action                   );
    c_client_identifier            constant number := power(2, s_client_identifier        );
    c_service_name                 constant number := power(2, s_service_name             );

    -- bitfield specifying which columns to group by in sampled session activity (ASH)
    g_ash_grouping  number := 63; -- test



  /*---------------------------------------------------
    -- proc for outputting data to trace or dbms_output
    ---------------------------------------------------*/
    procedure output(p_txt in varchar2) is
    begin

        if (getopt('&snapper_options', 'out') is not null)
            or
           (getopt('&snapper_options', 'out') is null and getopt('&snapper_options', 'trace') is null)
        then
            dbms_output.put_line(p_txt);
        end if;

        -- The block below is a sqlplus trick for conditionally commenting out PL/SQL code
        &_IF_DBMS_SYSTEM_ACCESSIBLE
        if getopt('&snapper_options', 'trace') is not null then
            sys.dbms_system.ksdwrt(1, p_txt);
            sys.dbms_system.ksdfls;
        end if;
        -- */
    end; -- output

  /*---------------------------------------------------
    -- proc for outputting data, utilizing global vars
    ---------------------------------------------------*/
    procedure fout is
        l_output_username VARCHAR2(30);
    begin

--      output( 'DEBUG, Entering fout(), b='||to_char(b)||' sn(s2(b).statistic#='||s2(b).statistic# );
--      output( 'DEBUG, In fout(), a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count);

        if output_username = 1 then
            begin
                l_output_username := nvl( g_sessions(s2(b).sid).username, substr(g_sessions(s2(b).sid).program, instr(g_sessions(s2(b).sid).program,'(')) );
            exception
                when no_data_found then l_output_username := 'error';
                when others then raise;
            end;
        end if;
        
        output( CASE WHEN output_header   = 1 THEN 'SID= ' END
             || CASE WHEN output_sid      = 1 THEN to_char(s2(b).sid,'999999')||', ' END
             || CASE WHEN output_username = 1 THEN rpad(CASE s2(b).sid WHEN -1 THEN ' ' ELSE l_output_username END, 10)||', ' END
             || CASE WHEN output_time     = 1 THEN to_char(d1, 'YYYYMMDD HH24:MI:SS')||', ' END
             || CASE WHEN output_seconds  = 1 THEN to_char(case (d2-d1) when 0 then &snapper_sleep else (d2-d1) * 86400 end, '9999999')||', ' END
             || CASE WHEN output_stype    = 1 THEN s2(b).stype||', ' END
             || CASE WHEN output_sname    = 1 THEN rpad(sn(s2(b).statistic#).name, 40, ' ')||', ' END
             || CASE WHEN output_delta    = 1 THEN to_char(delta, '999999999999')||', ' END
             || CASE WHEN output_delta_s  = 1 THEN to_char(delta/(case (d2-d1) when 0 then &snapper_sleep else (d2-d1) * 86400 end),'999999999')||', ' END
             || CASE WHEN output_hdelta   = 1 THEN lpad(tptformat(delta, s2(b).stype), 10, ' ')||', ' END
             || CASE WHEN output_hdelta_s = 1 THEN lpad(tptformat(delta/(case (d2-d1) when 0 then &snapper_sleep else (d2-d1)* 86400 end ), s2(b).stype), 10, ' ')||', ' END
             || CASE WHEN output_percent  = 1 THEN CASE WHEN s2(b).stype IN ('TIME','WAIT') THEN to_char(delta/CASE (d2-d1) WHEN 0 THEN &snapper_sleep ELSE (d2-d1) * 86400 END / 10000, '9999.9')||'%,' END END
             || CASE WHEN output_pcthist  = 1 THEN CASE WHEN s2(b).stype IN ('TIME','WAIT') THEN rpad(' '||rpad('|', ceil(round(delta/CASE (d2-d1) WHEN 0 THEN &snapper_sleep ELSE (d2-d1) * 86400 END / 100000,1))+1, '@'),12,' ')||'|' END END
        );

    end;

  /*---------------------------------------------------
    -- function for converting large numbers to human-readable format
    ---------------------------------------------------*/
    function tptformat( p_num in number,
                        p_stype in varchar2 default 'STAT',
                        p_precision in number default 2,
                        p_base in number default 10,    -- for KiB/MiB formatting use
                        p_grouplen in number default 3  -- p_base=2 and p_grouplen=10
                      )
                      return varchar2
    is
    begin

        if p_stype in ('WAIT','TIME') then

            return
                round(
                    p_num / power( p_base , trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) ), p_precision
                )
                || case trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen))
                       when 0            then 'us'
                       when 1            then 'us'
                       when p_grouplen*1 then 'ms'
                       when p_grouplen*2 then 's'
                       when p_grouplen*3 then 'ks'
                       when p_grouplen*4 then 'Ms'
                       else '*'||p_base||'^'||to_char( trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) )||' us'
                    end;

        else

            return
                round(
                    p_num / power( p_base , trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) ), p_precision
                )
                || case trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen))
                       when 0            then ''
                       when 1            then ''
                       when p_grouplen*1 then 'k'
                       when p_grouplen*2 then 'M'
                       when p_grouplen*3 then 'G'
                       when p_grouplen*4 then 'T'
                       when p_grouplen*5 then 'P'
                       when p_grouplen*6 then 'E'
                       else '*'||p_base||'^'||to_char( trunc(log(p_base,abs(p_num)))-trunc(mod(log(p_base,abs(p_num)),p_grouplen)) )
                    end;

        end if;

    end; -- tptformat

  /*---------------------------------------------------
    -- simple function for parsing arguments from parameter string
    ---------------------------------------------------*/
    function getopt( p_parvalues in varchar2,
                     p_extract in varchar2,
                     p_delim in varchar2 default ','
                   ) return varchar2
    is
        ret varchar(1000) := NULL;
    begin

      -- dbms_output.put('p_parvalues = ['||p_parvalues||'] ' );
      -- dbms_output.put('p_extract = ['||p_extract||'] ' );

        if lower(p_parvalues) like lower(p_extract)||'%'
        or lower(p_parvalues) like '%'||p_delim||lower(p_extract)||'%' then

            ret :=
                nvl (
                    substr(p_parvalues,
                            instr(p_parvalues, p_extract)+length(p_extract),
                            case
                                instr(
                                    substr(p_parvalues,
                                            instr(p_parvalues, p_extract)+length(p_extract)
                                    )
                                    , p_delim
                                )
                            when 0 then length(p_parvalues)
                            else
                                instr(
                                    substr(p_parvalues,
                                            instr(p_parvalues, p_extract)+length(p_extract)
                                    )
                                    , p_delim
                                ) - 1
                            end
                    )
                    , chr(0) -- in case parameter was specified but with no value
                );

        else
            ret := null; -- no parameter found
        end if;

      -- dbms_output.put_line('ret = ['||replace(ret,chr(0),'\0')||']');

        return ret;

    end; -- getopt

  /*---------------------------------------------------
    -- proc for getting session list with username, osuser, machine etc
    ---------------------------------------------------*/
   procedure get_sessions is
       tmp_sessions sestab;
   begin

       select
           *
       bulk collect into
            tmp_sessions
       from
            v$session
       where
            sid in (&snapper_sid);

       g_sessions := g_empty_sessions;

       for i in 1..tmp_sessions.count loop
           g_sessions(tmp_sessions(i).sid) := tmp_sessions(i);
       end loop;

   end; -- get_sessions

  /*---------------------------------------------------
    -- function for getting session list with username, osuser, machine etc
    -- this func does not update the g_sessions global array but returns session info as return value
    ---------------------------------------------------*/
   function get_sessions return sestab is
       tmp_sessions sestab;
       l_return_sessions sestab; 
   begin

       select
           *
       bulk collect into
            tmp_sessions
       from
            v$session
       where
            sid in (&snapper_sid);

       for i in 1..tmp_sessions.count loop
           --output('get_sessions i='||i||' sid='||tmp_sessions(i).sid);
           l_return_sessions(tmp_sessions(i).sid) := tmp_sessions(i);
       end loop;
       
       return l_return_sessions;

   end; -- get_sessions



    /*---------------------------------------------------
    -- functions for extracting and converting v$session
    -- records to varchar2
    ---------------------------------------------------*/
   function sitem(p in varchar2) return varchar2 as
   begin
      return '<'||translate(p, '<>', '__')||'>';
   end; -- sitem varchar2

   function sitem(p in number) return varchar2 as
   begin
      return '<'||to_char(p)||'>';
   end; -- sitem number 

   function sitem(p in date) return varchar2 as
   begin
      return '<'||to_char(p, 'YYYY-MM-DD HH24:MI:SS')||'>';
   end; -- sitem date

   function sitem_raw(p in raw) return varchar2 as
   begin
      return '<'||upper(rawtohex(p))||'>';
   end; -- sitem_raw


   /*---------------------------------------------------
   -- proc for resetting the snapper ash array
   ---------------------------------------------------*/
   procedure reset_ash is
   begin
      g_ash_samples_taken := 0;
      -- clear g_ash
      g_ash := new sys.dbms_debug_vc2coll(); 
   end; -- reset_ash


   /*---------------------------------------------------
   -- proc for getting ash style samples from v$session 
   -- (and v$session_wait in 9i)
   ---------------------------------------------------*/
   procedure extract_ash is
       ash_i number;
       s v$session%rowtype;
       
   begin
       -- keep track how many times we sampled v$session so we could calculate averages later on
       g_ash_samples_taken := g_ash_samples_taken + 1;
       --output('g_sessions.count='||g_sessions.count);
       ash_i := g_sessions.first;

       while ash_i is not null loop 

          s := g_sessions(ash_i);
          -- only extract active sessions, TODO: get rid of wait_class for 9i compatibility
          if -- active, on cpu
              (s.status = 'ACTIVE' and s.state != 'WAITING' and s.sid != g_mysid) 
          or -- active, waiting for non-idle wait
              (s.status = 'ACTIVE' and s.state = 'WAITING' and s.wait_class != 'Idle' and s.sid != g_mysid) 
          then 
             --output('extract_ash: i='||i||' sid='||s.sid||' hv='||s.sql_hash_value||' sqlid='||s.sql_id);

             -- if not actually waiting for anything, clear the past wait event details
             if s.state != 'WAITING' then 
                 s.state:='ON CPU';
                 s.event:='ON CPU';
                 s.wait_class:='ON CPU';
                 s.p1:=NULL;
                 s.p2:=NULL;
                 s.p3:=NULL;
             end if;

             g_ash.extend;

             -- max length 1000 bytes (due dbms_debug_vc2coll)
             g_ash(g_ash.count) := substr(
                            sitem(s.sid)                    --  1
                          ||sitem(s.username)               --  2  -- 30 bytes
                          ||sitem(s.machine)                --  3  -- 64 bytes
                          ||sitem(s.terminal)               --  4  -- 30 bytes
                          ||sitem(s.program)                --  5  -- 48 bytes
                          ||sitem(s.event)                  --  6  -- 64 bytes
                          ||sitem(s.wait_class)             --  7  -- 64 bytes, 10g+
                          ||sitem(s.state)                  --  8 
                          ||sitem(s.p1)                     --  9
                          ||sitem(s.p2)                     -- 10
                          ||sitem(s.p3)                     -- 11
                          ||sitem(s.row_wait_obj#)          -- 12
                          ||sitem(s.row_wait_file#)         -- 13
                          ||sitem(s.row_wait_block#)        -- 14
                          ||sitem(s.row_wait_row#)          -- 15
                          ||sitem(s.blocking_session_status) -- 16  -- 10g+
           &_NO_BLK_INST  ||sitem('N/A')                    -- 17   -- 10gR2+
          &_YES_BLK_INST  ||sitem(s.blocking_instance)      -- 17   -- 10gR2+
                          ||sitem(s.blocking_session)       -- 18   -- 10g+
                          ||sitem(s.sql_hash_value)         -- 19
                          ||sitem(s.sql_id)                 -- 20
                          ||sitem(s.sql_child_number)       -- 21   -- 10g+
      &_NO_PLSQL_OBJ_ID   ||sitem('N/A')                    -- 22
      &_NO_PLSQL_OBJ_ID   ||sitem('N/A')                    -- 23
      &_NO_PLSQL_OBJ_ID   ||sitem('N/A')                    -- 24
      &_NO_PLSQL_OBJ_ID   ||sitem('N/A')                    -- 25
     &_YES_PLSQL_OBJ_ID   ||sitem(s.plsql_entry_object_id)  -- 22
     &_YES_PLSQL_OBJ_ID   ||sitem(s.plsql_entry_subprogram_id) -- 23
     &_YES_PLSQL_OBJ_ID   ||sitem(s.plsql_object_id)        -- 24
     &_YES_PLSQL_OBJ_ID   ||sitem(s.plsql_subprogram_id)    -- 25
                          ||sitem(s.module)                 -- 26  -- 48 bytes
                          ||sitem(s.action)                 -- 27  -- 32 bytes
                          ||sitem(s.client_identifier)      -- 28  -- 64 bytes
                          ||sitem(s.service_name)           -- 29  -- 64 bytes
                    , 1, 1000);
             
          end if; -- sample is of an active session
          
          ash_i := g_sessions.next(ash_i);
       
       end loop;

   exception
       when no_data_found then output('error in extract_ash(): no_data_found for item '||i);
   end; -- extract_ash


   /*---------------------------------------------------
    -- proc for querying performance data into collections
    ---------------------------------------------------*/
   procedure snap( p_snapdate in out date, p_stats in out stab ) is

    lv_include_stat  varchar2(1000) := nvl( lower(getopt('&snapper_options', 'sinclude=' )), '%');
    lv_include_latch varchar2(1000) := nvl( lower(getopt('&snapper_options', 'linclude=' )), '%');
    lv_include_time  varchar2(1000) := nvl( lower(getopt('&snapper_options', 'tinclude=' )), '%');
    lv_include_wait  varchar2(1000) := nvl( lower(getopt('&snapper_options', 'winclude=' )), '%');


   begin
        
        p_snapdate := sysdate;

        select *
        bulk collect into p_stats
        from (
                                         select 'STAT' stype, sid, statistic# - pls_adjust statistic#, value
                                         from v$sesstat
                                         where sid in (&snapper_sid)
                                         and  (lv_gather like '%s%' or lv_gather like '%a%')
                                         and statistic# in (select /*+ no_unnest */ statistic# from v$statname
                                                            where lower(name) like '%'||lv_include_stat||'%'
                    &_IF_ORA10_OR_HIGHER                    or regexp_like (name, lv_include_stat, 'i')
                                                           )
                                         --
                                         union all
                                         select
                                                'WAIT', sw.sid,
                                                en.event# + (select count(*) from v$statname) + 1 - pls_adjust,
                                                nvl(se.time_waited_micro,0) + ( decode(se.event||sw.state, sw.event||'WAITING', sw.seconds_in_wait, 0) * 1000000 ) value
                                         from v$session_wait sw, v$session_event se, v$event_name en
                                         where sw.sid = se.sid
                                         and   se.event = en.name
                                         and   se.sid in (&snapper_sid)
                                         and   (lv_gather like '%w%' or lv_gather like '%a%')
                                         and   event#  in (select event# from v$event_name
                                                            where lower(name) like '%'||lv_include_wait||'%'
                    &_IF_ORA10_OR_HIGHER                    or    regexp_like (name, lv_include_wait, 'i')
                                                           )
                                         --
                    &_IF_ORA10_OR_HIGHER union all
                    &_IF_ORA10_OR_HIGHER select 'TIME' stype, sid, stat_id - pls_adjust statistic#, value
                    &_IF_ORA10_OR_HIGHER from v$sess_time_model
                    &_IF_ORA10_OR_HIGHER where sid in (&snapper_sid)
                    &_IF_ORA10_OR_HIGHER and   (lv_gather like '%t%' or lv_gather like '%a%')
                    &_IF_ORA10_OR_HIGHER and stat_id in (select stat_id from v$sys_time_model
                    &_IF_ORA10_OR_HIGHER                    where lower(stat_name) like '%'||lv_include_time||'%'
                    &_IF_ORA10_OR_HIGHER                    or    regexp_like (stat_name, lv_include_time, 'i')
                    &_IF_ORA10_OR_HIGHER                   )
                                         --
                                         union all
                                         select 'LATG', -1 sid,
                                               l.latch# +
                                                   (select count(*) from v$statname) +
                                                   (select count(*) from v$event_name) +
                                                   1 - pls_adjust statistic#,
                                               l.gets + l.immediate_gets value
                                         from v$latch l
                                         where
                                             (lv_gather like '%l%' or lv_gather like '%a%')
                                         and latch# in (select latch# from v$latchname
                                                        where lower(name) like '%'||lv_include_latch||'%'
                    &_IF_ORA10_OR_HIGHER                or    regexp_like (name, lv_include_latch, 'i')
                                                       )
                                         --
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 union all
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 select 'BUFG', -1 sid,
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11       s.indx +
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11           (select count(*) from v$statname) +
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11           (select count(*) from v$event_name) +
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11           (select count(*) from v$latch) +
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11           1 - pls_adjust statistic#,
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11       s.why0+s.why1+s.why2 value
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 from x$kcbsw s, x$kcbwh w
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 where
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11       s.indx = w.indx
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 and   s.why0+s.why1+s.why2 > 0
  &_IF_X_ACCESSIBLE &_IF_LOWER_THAN_ORA11 and   (lv_gather like '%b%' or lv_gather like '%a%')
                                          --
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  union all
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  select 'BUFG', -1 sid,
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        sw.indx +
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER            (select count(*) from v$statname) +
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER            (select count(*) from v$event_name) +
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER            (select count(*) from v$latch) +
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER            1 - pls_adjust statistic#,
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        why.why0+why.why1+why.why2+sw.other_wait value
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  from
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        x$kcbuwhy why,
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        x$kcbwh       dsc,
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        x$kcbsw       sw
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  where
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        why.indx = dsc.indx
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  and   why.why0 + why.why1 + why.why2 + sw.other_wait > 0
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  and   dsc.indx = sw.indx
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  and   why.indx = sw.indx
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER        -- deliberate cartesian join
  &_IF_X_ACCESSIBLE &_IF_ORA11_OR_HIGHER  and   (lv_gather like '%b%' or lv_gather like '%a%')
                                         --
                                         union all
                                         select 'ENQG', -1 sid,
                                               ascii(substr(e.eq_type,1,1))*256 + ascii(substr(e.eq_type,2,1)) +
                                                   (select count(*) from v$statname) +
                                                   (select count(*) from v$event_name) +
                                                   (select count(*) from v$latch) +
  &_IF_X_ACCESSIBLE                                (select count(*) from x$kcbwh) +
                                                   1 - pls_adjust statistic#,
                                               e.total_req# value
                                         from v$enqueue_stat e
                                         where
                                               (lv_gather like '%e%' or lv_gather like '%a%')
        ) snapper_stats
        order by sid, stype, statistic#;
   end snap;


   /*---------------------------------------------------
    -- proc for dumping ASH data out in grouped
    -- and ordered fashion
    ---------------------------------------------------*/
    procedure out_ash( p_ash_columns in varchar2, p_topn in number := 10 ) as

        -- whether to print given column or not
        p_sid                         number := 0;
        p_username                    number := 0;
        p_machine                     number := 0;
        p_terminal                    number := 0;
        p_program                     number := 0;
        p_event                       number := 0;
        p_wait_class                  number := 0;
        p_state                       number := 0;
        p_p1                          number := 0;
        p_p2                          number := 0;
        p_p3                          number := 0;
        p_row_wait_obj#               number := 0;
        p_row_wait_file#              number := 0;
        p_row_wait_block#             number := 0;
        p_row_wait_row#               number := 0;
        p_blocking_session_status     number := 0;
        p_blocking_instance           number := 0;
        p_blocking_session            number := 0;
        p_sql_hash_value              number := 0;
        p_sql_id                      number := 0;
        p_sql_child_number            number := 0;
        p_plsql_entry_object_id       number := 0;
        p_plsql_entry_subprogram_id   number := 0;
        p_plsql_object_id             number := 0;
        p_plsql_subprogram_id         number := 0;
        p_module                      number := 0;
        p_action                      number := 0;
        p_client_identifier           number := 0;
        p_service_name                number := 0;

        -- temporary variables for holding session details (for later formatting)
        o_sid                         varchar2(100);
        o_username                    varchar2(100);
        o_machine                     varchar2(100);
        o_terminal                    varchar2(100);
        o_program                     varchar2(100);
        o_event                       varchar2(100);
        o_wait_class                  varchar2(100);
        o_state                       varchar2(100);
        o_p1                          varchar2(100);
        o_p2                          varchar2(100);
        o_p3                          varchar2(100);
        o_row_wait_obj#               varchar2(100);
        o_row_wait_file#              varchar2(100);
        o_row_wait_block#             varchar2(100);
        o_row_wait_row#               varchar2(100);
        o_blocking_session_status     varchar2(100);
        o_blocking_instance           varchar2(100);
        o_blocking_session            varchar2(100);
        o_sql_hash_value              varchar2(100);
        o_sql_id                      varchar2(100);
        o_sql_child_number            varchar2(100);
        o_plsql_entry_object_id       varchar2(100);
        o_plsql_entry_subprogram_id   varchar2(100);
        o_plsql_object_id             varchar2(100);
        o_plsql_subprogram_id         varchar2(100);
        o_module                      varchar2(100);
        o_action                      varchar2(100);
        o_client_identifier           varchar2(100);
        o_service_name                varchar2(100);

        -- helper local vars
        l_ash_grouping                number := 0;
        l_output_line                 varchar2(4000);
        l_ash_header_line             varchar2(4000);

    begin

      -- bail out if no ASH samples recorded
      if g_ash.count = 0 then 
          output('    <No active sessions captured during the sampling period>');
          return;
      end if;


      l_ash_header_line := 'Active%';

      -- ash,ash1,ash2,ash3 parameter column group tokenizer
      for s in (
          SELECT LEVEL
                 , SUBSTR
                   ( TOKEN
                    , DECODE(LEVEL, 1, 1, INSTR(TOKEN, DELIMITER, 1, LEVEL-1)+1)
                    , INSTR(TOKEN, DELIMITER, 1, LEVEL) -
                   DECODE(LEVEL, 1, 1, INSTR(TOKEN, DELIMITER, 1, LEVEL-1)+1)
                   ) TOKEN
          FROM ( SELECT REPLACE(  LOWER(p_ash_columns)  ,' ','')||'+' AS TOKEN
                 , '+'                        AS DELIMITER
                 FROM DUAL
          )
          CONNECT BY 
              INSTR(TOKEN, DELIMITER, 1, LEVEL)>0
          ORDER BY 
              LEVEL ASC
      ) loop


          case s.token
              -- actual column names in v$session
              when 'sid'                          then l_ash_grouping := l_ash_grouping + c_sid                      ; l_ash_header_line := l_ash_header_line || ' | ' || lpad('SID'                       , w_sid                      , ' ');
              when 'username'                     then l_ash_grouping := l_ash_grouping + c_username                 ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('USERNAME'                  , w_username                 , ' ');
              when 'machine'                      then l_ash_grouping := l_ash_grouping + c_machine                  ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('MACHINE'                   , w_machine                  , ' ');
              when 'terminal'                     then l_ash_grouping := l_ash_grouping + c_terminal                 ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('TERMINAL'                  , w_terminal                 , ' ');
              when 'program'                      then l_ash_grouping := l_ash_grouping + c_program                  ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PROGRAM'                   , w_program                  , ' ');
              when 'event'                        then l_ash_grouping := l_ash_grouping + c_event                    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('EVENT'                     , w_event                    , ' ');
              when 'wait_class'                   then l_ash_grouping := l_ash_grouping + c_wait_class               ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('WAIT_CLASS'                , w_wait_class               , ' ');
              when 'state'                        then l_ash_grouping := l_ash_grouping + c_state                    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('STATE'                     , w_state                    , ' ');
              when 'p1'                           then l_ash_grouping := l_ash_grouping + c_p1                       ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('P1'                        , w_p1                       , ' ');
              when 'p2'                           then l_ash_grouping := l_ash_grouping + c_p2                       ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('P2'                        , w_p2                       , ' ');
              when 'p3'                           then l_ash_grouping := l_ash_grouping + c_p3                       ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('P3'                        , w_p3                       , ' ');
              when 'row_wait_obj#'                then l_ash_grouping := l_ash_grouping + c_row_wait_obj#            ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_OBJ#'             , w_row_wait_obj#            , ' ');
              when 'row_wait_file#'               then l_ash_grouping := l_ash_grouping + c_row_wait_file#           ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_FILE#'            , w_row_wait_file#           , ' ');
              when 'row_wait_block#'              then l_ash_grouping := l_ash_grouping + c_row_wait_block#          ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_BLOCK#'           , w_row_wait_block#          , ' ');
              when 'row_wait_row#'                then l_ash_grouping := l_ash_grouping + c_row_wait_row#            ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_ROW#'             , w_row_wait_row#            , ' ');
              when 'blocking_session_status'      then l_ash_grouping := l_ash_grouping + c_blocking_session_status  ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_SESSION_STATUS'   , w_blocking_session_status  , ' ');
              when 'blocking_instance'            then l_ash_grouping := l_ash_grouping + c_blocking_instance        ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_INSTANCE'         , w_blocking_instance        , ' ');
              when 'blocking_session'             then l_ash_grouping := l_ash_grouping + c_blocking_session         ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_SESSION'          , w_blocking_session         , ' ');
              when 'sql_hash_value'               then l_ash_grouping := l_ash_grouping + c_sql_hash_value           ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_HASH_VALUE'            , w_sql_hash_value           , ' ');
              when 'sql_id'                       then l_ash_grouping := l_ash_grouping + c_sql_id                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_ID'                    , w_sql_id                   , ' ');
              when 'sql_child_number'             then l_ash_grouping := l_ash_grouping + c_sql_child_number         ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_CHILD_NUMBER'          , w_sql_child_number         , ' ');
              when 'plsql_entry_object_id'        then l_ash_grouping := l_ash_grouping + c_plsql_entry_object_id    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_ENTRY_OBJECT_ID'     , w_plsql_entry_object_id    , ' ');
              when 'plsql_entry_subprogram_id'    then l_ash_grouping := l_ash_grouping + c_plsql_entry_subprogram_id; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_ENTRY_SUBPROGRAM_ID' , w_plsql_entry_subprogram_id, ' ');
              when 'plsql_object_id'              then l_ash_grouping := l_ash_grouping + c_plsql_object_id          ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_OBJECT_ID'           , w_plsql_object_id          , ' ');
              when 'plsql_subprogram_id'          then l_ash_grouping := l_ash_grouping + c_plsql_subprogram_id      ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_SUBPROGRAM_ID'       , w_plsql_subprogram_id      , ' ');
              when 'module'                       then l_ash_grouping := l_ash_grouping + c_module                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('MODULE'                    , w_module                   , ' ');
              when 'action'                       then l_ash_grouping := l_ash_grouping + c_action                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ACTION'                    , w_action                   , ' ');
              when 'client_identifier'            then l_ash_grouping := l_ash_grouping + c_client_identifier        ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('CLIENT_IDENTIFIER'         , w_client_identifier        , ' ');
              when 'service_name'                 then l_ash_grouping := l_ash_grouping + c_service_name             ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SERVICE_NAME'              , w_service_name             , ' ');
              -- aliases for convenience (only either real name or alias should be used together at the same time)                                  , ' ');
              when 'user'                         then l_ash_grouping := l_ash_grouping + c_username                 ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('USERNAME'                  , w_username                 , ' ');
              when 'obj'                          then l_ash_grouping := l_ash_grouping + c_row_wait_obj#            ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_OBJ#'             , w_row_wait_obj#            , ' ');
              when 'file'                         then l_ash_grouping := l_ash_grouping + c_row_wait_file#           ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_FILE#'            , w_row_wait_file#           , ' ');
              when 'block'                        then l_ash_grouping := l_ash_grouping + c_row_wait_block#          ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_BLOCK#'           , w_row_wait_block#          , ' ');
              when 'row'                          then l_ash_grouping := l_ash_grouping + c_row_wait_row#            ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ROW_WAIT_ROW#'             , w_row_wait_row#            , ' ');
              when 'bss'                          then l_ash_grouping := l_ash_grouping + c_blocking_session_status  ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_SESSION_STATUS'   , w_blocking_session_status  , ' ');
              when 'bsi'                          then l_ash_grouping := l_ash_grouping + c_blocking_instance        ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_INSTANCE'         , w_blocking_instance        , ' ');
              when 'bs'                           then l_ash_grouping := l_ash_grouping + c_blocking_session         ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('BLOCKING_SESSION'          , w_blocking_session         , ' ');
              when 'sql'                          then l_ash_grouping := l_ash_grouping + c_sql_hash_value           ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_HASH_VALUE'            , w_sql_hash_value           , ' ');
              when 'sqlid'                        then l_ash_grouping := l_ash_grouping + c_sql_id                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_ID'                    , w_sql_id                   , ' ');
              when 'child'                        then l_ash_grouping := l_ash_grouping + c_sql_child_number         ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SQL_CHILD_NUMBER'          , w_sql_child_number         , ' ');
              when 'plsql_eoid'                   then l_ash_grouping := l_ash_grouping + c_plsql_entry_object_id    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_ENTRY_OBJECT_ID'     , w_plsql_entry_object_id    , ' ');
              when 'plsql_esubpid'                then l_ash_grouping := l_ash_grouping + c_plsql_entry_subprogram_id; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_ENTRY_SUBPROGRAM_ID' , w_plsql_entry_subprogram_id, ' ');
              when 'plsql_oid'                    then l_ash_grouping := l_ash_grouping + c_plsql_object_id          ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_OBJECT_ID'           , w_plsql_object_id          , ' ');
              when 'plsql_subpid'                 then l_ash_grouping := l_ash_grouping + c_plsql_subprogram_id      ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('PLSQL_SUBPROGRAM_ID'       , w_plsql_subprogram_id      , ' ');
              when 'mod'                          then l_ash_grouping := l_ash_grouping + c_module                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('MODULE'                    , w_module                   , ' ');
              when 'act'                          then l_ash_grouping := l_ash_grouping + c_action                   ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('ACTION'                    , w_action                   , ' ');
              when 'cid'                          then l_ash_grouping := l_ash_grouping + c_client_identifier        ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('CLIENT_IDENTIFIER'         , w_client_identifier        , ' ');
              when 'service'                      then l_ash_grouping := l_ash_grouping + c_service_name             ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('SERVICE_NAME'              , w_service_name             , ' ');
              when 'wait_event'                   then l_ash_grouping := l_ash_grouping + c_event                    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('EVENT'                     , w_event                    , ' ');
              when 'wait_state'                   then l_ash_grouping := l_ash_grouping + c_state                    ; l_ash_header_line := l_ash_header_line || ' | ' || rpad('STATE'                     , w_state                    , ' ');
          else
              null;
              -- raise_application_error(-20000, 'Invalid ASH column name');
          end case; -- case s.token

      end loop; -- tokenizer

      output(' ');
      output(lpad('-',length(l_ash_header_line),'-'));
      output(l_ash_header_line);
      output(lpad('-',length(l_ash_header_line),'-'));

      -- this is needed for "easy" sorting and group by ops (without any custom stored object types!)
      for i in (
          with raw_records as (
             select column_value rec from table(cast(g_ash as sys.dbms_debug_vc2coll))
          ),
          ash_records as (
             select 
                 substr(r.rec, instr(r.rec, '<', 1,  1)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  1)+1), '>')-1) sid
               , substr(r.rec, instr(r.rec, '<', 1,  2)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  2)+1), '>')-1) username
               , substr(r.rec, instr(r.rec, '<', 1,  3)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  3)+1), '>')-1) machine
               , substr(r.rec, instr(r.rec, '<', 1,  4)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  4)+1), '>')-1) terminal
               , substr(r.rec, instr(r.rec, '<', 1,  5)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  5)+1), '>')-1) program
               , substr(r.rec, instr(r.rec, '<', 1,  6)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  6)+1), '>')-1) event
               , substr(r.rec, instr(r.rec, '<', 1,  7)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  7)+1), '>')-1) wait_class
               , substr(r.rec, instr(r.rec, '<', 1,  8)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  8)+1), '>')-1) state
               , substr(r.rec, instr(r.rec, '<', 1,  9)+1, instr (substr(r.rec, instr(r.rec, '<', 1,  9)+1), '>')-1) p1
               , substr(r.rec, instr(r.rec, '<', 1, 10)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 10)+1), '>')-1) p2
               , substr(r.rec, instr(r.rec, '<', 1, 11)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 11)+1), '>')-1) p3
               , substr(r.rec, instr(r.rec, '<', 1, 12)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 12)+1), '>')-1) row_wait_obj#
               , substr(r.rec, instr(r.rec, '<', 1, 13)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 13)+1), '>')-1) row_wait_file#
               , substr(r.rec, instr(r.rec, '<', 1, 14)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 14)+1), '>')-1) row_wait_block#
               , substr(r.rec, instr(r.rec, '<', 1, 15)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 15)+1), '>')-1) row_wait_row#
               , substr(r.rec, instr(r.rec, '<', 1, 16)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 16)+1), '>')-1) blocking_session_status
               , substr(r.rec, instr(r.rec, '<', 1, 17)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 17)+1), '>')-1) blocking_instance
               , substr(r.rec, instr(r.rec, '<', 1, 18)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 18)+1), '>')-1) blocking_session
               , substr(r.rec, instr(r.rec, '<', 1, 19)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 19)+1), '>')-1) sql_hash_value
               , substr(r.rec, instr(r.rec, '<', 1, 20)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 20)+1), '>')-1) sql_id
               , substr(r.rec, instr(r.rec, '<', 1, 21)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 21)+1), '>')-1) sql_child_number
               , substr(r.rec, instr(r.rec, '<', 1, 22)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 22)+1), '>')-1) plsql_entry_object_id
               , substr(r.rec, instr(r.rec, '<', 1, 23)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 23)+1), '>')-1) plsql_entry_subprogram_id
               , substr(r.rec, instr(r.rec, '<', 1, 24)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 24)+1), '>')-1) plsql_object_id
               , substr(r.rec, instr(r.rec, '<', 1, 25)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 25)+1), '>')-1) plsql_subprogram_id
               , substr(r.rec, instr(r.rec, '<', 1, 26)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 26)+1), '>')-1) module
               , substr(r.rec, instr(r.rec, '<', 1, 27)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 27)+1), '>')-1) action
               , substr(r.rec, instr(r.rec, '<', 1, 28)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 28)+1), '>')-1) client_identifier
               , substr(r.rec, instr(r.rec, '<', 1, 29)+1, instr (substr(r.rec, instr(r.rec, '<', 1, 29)+1), '>')-1) service_name              
             from 
                raw_records r
          )
          select * from (
            select
               decode(bitand(l_ash_grouping, power(2, s_sid                           )), 0, chr(0), sid                           ) as sid                           
             , decode(bitand(l_ash_grouping, power(2, s_username                      )), 0, chr(0), username                      ) as username                      
             , decode(bitand(l_ash_grouping, power(2, s_machine                       )), 0, chr(0), machine                       ) as machine                       
             , decode(bitand(l_ash_grouping, power(2, s_terminal                      )), 0, chr(0), terminal                      ) as terminal                      
             , decode(bitand(l_ash_grouping, power(2, s_program                       )), 0, chr(0), program                       ) as program                       
             , decode(bitand(l_ash_grouping, power(2, s_event                         )), 0, chr(0), event                         ) as event                         
             , decode(bitand(l_ash_grouping, power(2, s_wait_class                    )), 0, chr(0), wait_class                    ) as wait_class                    
             , decode(bitand(l_ash_grouping, power(2, s_state                         )), 0, chr(0), state                         ) as state                         
             , decode(bitand(l_ash_grouping, power(2, s_p1                            )), 0, chr(0), p1                            ) as p1                            
             , decode(bitand(l_ash_grouping, power(2, s_p2                            )), 0, chr(0), p2                            ) as p2                            
             , decode(bitand(l_ash_grouping, power(2, s_p3                            )), 0, chr(0), p3                            ) as p3                            
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_obj#                 )), 0, chr(0), row_wait_obj#                 ) as row_wait_obj#                 
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_file#                )), 0, chr(0), row_wait_file#                ) as row_wait_file#                
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_block#               )), 0, chr(0), row_wait_block#               ) as row_wait_block#               
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_row#                 )), 0, chr(0), row_wait_row#                 ) as row_wait_row#                 
             , decode(bitand(l_ash_grouping, power(2, s_blocking_session_status       )), 0, chr(0), blocking_session_status       ) as blocking_session_status       
             , decode(bitand(l_ash_grouping, power(2, s_blocking_instance             )), 0, chr(0), blocking_instance             ) as blocking_instance             
             , decode(bitand(l_ash_grouping, power(2, s_blocking_session              )), 0, chr(0), blocking_session              ) as blocking_session              
             , decode(bitand(l_ash_grouping, power(2, s_sql_hash_value                )), 0, chr(0), sql_hash_value                ) as sql_hash_value                
             , decode(bitand(l_ash_grouping, power(2, s_sql_id                        )), 0, chr(0), sql_id                        ) as sql_id                        
             , decode(bitand(l_ash_grouping, power(2, s_sql_child_number              )), 0, chr(0), sql_child_number              ) as sql_child_number              
             , decode(bitand(l_ash_grouping, power(2, s_plsql_entry_object_id         )), 0, chr(0), plsql_entry_object_id         ) as plsql_entry_object_id         
             , decode(bitand(l_ash_grouping, power(2, s_plsql_entry_subprogram_id     )), 0, chr(0), plsql_entry_subprogram_id     ) as plsql_entry_subprogram_id     
             , decode(bitand(l_ash_grouping, power(2, s_plsql_object_id               )), 0, chr(0), plsql_object_id               ) as plsql_object_id               
             , decode(bitand(l_ash_grouping, power(2, s_plsql_subprogram_id           )), 0, chr(0), plsql_subprogram_id           ) as plsql_subprogram_id           
             , decode(bitand(l_ash_grouping, power(2, s_module                        )), 0, chr(0), module                        ) as module                        
             , decode(bitand(l_ash_grouping, power(2, s_action                        )), 0, chr(0), action                        ) as action                        
             , decode(bitand(l_ash_grouping, power(2, s_client_identifier             )), 0, chr(0), client_identifier             ) as client_identifier             
             , decode(bitand(l_ash_grouping, power(2, s_service_name                  )), 0, chr(0), service_name                  ) as service_name                  
             , count(*)/g_ash_samples_taken average_active_samples
            from
               ash_records a
            group by
               decode(bitand(l_ash_grouping, power(2, s_sid                           )), 0, chr(0), sid                           ) -- sid                           
             , decode(bitand(l_ash_grouping, power(2, s_username                      )), 0, chr(0), username                      ) -- username                      
             , decode(bitand(l_ash_grouping, power(2, s_machine                       )), 0, chr(0), machine                       ) -- machine                       
             , decode(bitand(l_ash_grouping, power(2, s_terminal                      )), 0, chr(0), terminal                      ) -- terminal                      
             , decode(bitand(l_ash_grouping, power(2, s_program                       )), 0, chr(0), program                       ) -- program                       
             , decode(bitand(l_ash_grouping, power(2, s_event                         )), 0, chr(0), event                         ) -- event                         
             , decode(bitand(l_ash_grouping, power(2, s_wait_class                    )), 0, chr(0), wait_class                    ) -- wait_class                    
             , decode(bitand(l_ash_grouping, power(2, s_state                         )), 0, chr(0), state                         ) -- state                         
             , decode(bitand(l_ash_grouping, power(2, s_p1                            )), 0, chr(0), p1                            ) -- p1                            
             , decode(bitand(l_ash_grouping, power(2, s_p2                            )), 0, chr(0), p2                            ) -- p2                            
             , decode(bitand(l_ash_grouping, power(2, s_p3                            )), 0, chr(0), p3                            ) -- p3                            
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_obj#                 )), 0, chr(0), row_wait_obj#                 ) -- row_wait_obj#                 
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_file#                )), 0, chr(0), row_wait_file#                ) -- row_wait_file#                
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_block#               )), 0, chr(0), row_wait_block#               ) -- row_wait_block#               
             , decode(bitand(l_ash_grouping, power(2, s_row_wait_row#                 )), 0, chr(0), row_wait_row#                 ) -- row_wait_row#                 
             , decode(bitand(l_ash_grouping, power(2, s_blocking_session_status       )), 0, chr(0), blocking_session_status       ) -- blocking_session_status       
             , decode(bitand(l_ash_grouping, power(2, s_blocking_instance             )), 0, chr(0), blocking_instance             ) -- blocking_instance             
             , decode(bitand(l_ash_grouping, power(2, s_blocking_session              )), 0, chr(0), blocking_session              ) -- blocking_session              
             , decode(bitand(l_ash_grouping, power(2, s_sql_hash_value                )), 0, chr(0), sql_hash_value                ) -- sql_hash_value                
             , decode(bitand(l_ash_grouping, power(2, s_sql_id                        )), 0, chr(0), sql_id                        ) -- sql_id                        
             , decode(bitand(l_ash_grouping, power(2, s_sql_child_number              )), 0, chr(0), sql_child_number              ) -- sql_child_number              
             , decode(bitand(l_ash_grouping, power(2, s_plsql_entry_object_id         )), 0, chr(0), plsql_entry_object_id         ) -- plsql_entry_object_id         
             , decode(bitand(l_ash_grouping, power(2, s_plsql_entry_subprogram_id     )), 0, chr(0), plsql_entry_subprogram_id     ) -- plsql_entry_subprogram_id     
             , decode(bitand(l_ash_grouping, power(2, s_plsql_object_id               )), 0, chr(0), plsql_object_id               ) -- plsql_object_id               
             , decode(bitand(l_ash_grouping, power(2, s_plsql_subprogram_id           )), 0, chr(0), plsql_subprogram_id           ) -- plsql_subprogram_id           
             , decode(bitand(l_ash_grouping, power(2, s_module                        )), 0, chr(0), module                        ) -- module                        
             , decode(bitand(l_ash_grouping, power(2, s_action                        )), 0, chr(0), action                        ) -- action                        
             , decode(bitand(l_ash_grouping, power(2, s_client_identifier             )), 0, chr(0), client_identifier             ) -- client_identifier             
             , decode(bitand(l_ash_grouping, power(2, s_service_name                  )), 0, chr(0), service_name                  ) -- service_name                  
           order by
              count(*)/g_ash_samples_taken desc
          )
          where rownum <= p_topn
      ) loop

          l_output_line := '';

          o_sid                         := CASE WHEN i.sid                            = chr(0) THEN null ELSE nvl(i.sid                           , ' ') END;
          o_username                    := CASE WHEN i.username                       = chr(0) THEN null ELSE nvl(i.username                      , ' ') END;
          o_machine                     := CASE WHEN i.machine                        = chr(0) THEN null ELSE nvl(i.machine                       , ' ') END;
          o_terminal                    := CASE WHEN i.terminal                       = chr(0) THEN null ELSE nvl(i.terminal                      , ' ') END;
          o_program                     := CASE WHEN i.program                        = chr(0) THEN null ELSE nvl(i.program                       , ' ') END;
          o_event                       := CASE WHEN i.event                          = chr(0) THEN null ELSE nvl(i.event                         , ' ') END;
          o_wait_class                  := CASE WHEN i.wait_class                     = chr(0) THEN null ELSE nvl(i.wait_class                    , ' ') END;
          o_state                       := CASE WHEN i.state                          = chr(0) THEN null ELSE nvl(i.state                         , ' ') END;
          o_p1                          := CASE WHEN i.p1                             = chr(0) THEN null ELSE nvl(i.p1                            , ' ') END;
          o_p2                          := CASE WHEN i.p2                             = chr(0) THEN null ELSE nvl(i.p2                            , ' ') END;
          o_p3                          := CASE WHEN i.p3                             = chr(0) THEN null ELSE nvl(i.p3                            , ' ') END;
          o_row_wait_obj#               := CASE WHEN i.row_wait_obj#                  = chr(0) THEN null ELSE nvl(i.row_wait_obj#                 , ' ') END;
          o_row_wait_file#              := CASE WHEN i.row_wait_file#                 = chr(0) THEN null ELSE nvl(i.row_wait_file#                , ' ') END;
          o_row_wait_block#             := CASE WHEN i.row_wait_block#                = chr(0) THEN null ELSE nvl(i.row_wait_block#               , ' ') END;
          o_row_wait_row#               := CASE WHEN i.row_wait_row#                  = chr(0) THEN null ELSE nvl(i.row_wait_row#                 , ' ') END;
          o_blocking_session_status     := CASE WHEN i.blocking_session_status        = chr(0) THEN null ELSE nvl(i.blocking_session_status       , ' ') END;
          o_blocking_instance           := CASE WHEN i.blocking_instance              = chr(0) THEN null ELSE nvl(i.blocking_instance             , ' ') END;
          o_blocking_session            := CASE WHEN i.blocking_session               = chr(0) THEN null ELSE nvl(i.blocking_session              , ' ') END;
          o_sql_hash_value              := CASE WHEN i.sql_hash_value                 = chr(0) THEN null ELSE nvl(i.sql_hash_value                , ' ') END;
          o_sql_id                      := CASE WHEN i.sql_id                         = chr(0) THEN null ELSE nvl(i.sql_id                        , ' ') END;
          o_sql_child_number            := CASE WHEN i.sql_child_number               = chr(0) THEN null ELSE nvl(i.sql_child_number              , ' ') END;
          o_plsql_entry_object_id       := CASE WHEN i.plsql_entry_object_id          = chr(0) THEN null ELSE nvl(i.plsql_entry_object_id         , ' ') END;
          o_plsql_entry_subprogram_id   := CASE WHEN i.plsql_entry_subprogram_id      = chr(0) THEN null ELSE nvl(i.plsql_entry_subprogram_id     , ' ') END;
          o_plsql_object_id             := CASE WHEN i.plsql_object_id                = chr(0) THEN null ELSE nvl(i.plsql_object_id               , ' ') END;
          o_plsql_subprogram_id         := CASE WHEN i.plsql_subprogram_id            = chr(0) THEN null ELSE nvl(i.plsql_subprogram_id           , ' ') END;
          o_module                      := CASE WHEN i.module                         = chr(0) THEN null ELSE nvl(i.module                        , ' ') END;
          o_action                      := CASE WHEN i.action                         = chr(0) THEN null ELSE nvl(i.action                        , ' ') END;
          o_client_identifier           := CASE WHEN i.client_identifier              = chr(0) THEN null ELSE nvl(i.client_identifier             , ' ') END;
          o_service_name                := CASE WHEN i.service_name                   = chr(0) THEN null ELSE nvl(i.service_name                  , ' ') END;


          -- print the activity % as the first column
          l_output_line := lpad(to_char(round(i.average_active_samples*100))||'%', w_activity_pct, ' ');

          -- loop through ash columns to find what to print and in which order
          for s in (
              SELECT LEVEL
                     , SUBSTR
                       ( TOKEN
                        , DECODE(LEVEL, 1, 1, INSTR(TOKEN, DELIMITER, 1, LEVEL-1)+1)
                        , INSTR(TOKEN, DELIMITER, 1, LEVEL) -
                       DECODE(LEVEL, 1, 1, INSTR(TOKEN, DELIMITER, 1, LEVEL-1)+1)
                       ) TOKEN
              FROM ( SELECT REPLACE(  LOWER(p_ash_columns)  ,' ','')||'+' AS TOKEN
                     , '+'                        AS DELIMITER
                     FROM DUAL
              )
              CONNECT BY 
                  INSTR(TOKEN, DELIMITER, 1, LEVEL)>0
              ORDER BY 
                  LEVEL ASC
          ) loop
              l_output_line := l_output_line || ' | ' ||
                  case s.token
                      -- actual column names in v$session
                      when 'sid'                          then lpad(o_sid                       , w_sid                      , ' ')
                      when 'username'                     then rpad(o_username                  , w_username                 , ' ')
                      when 'machine'                      then rpad(o_machine                   , w_machine                  , ' ')
                      when 'terminal'                     then rpad(o_terminal                  , w_terminal                 , ' ')
                      when 'program'                      then rpad(o_program                   , w_program                  , ' ')
                      when 'event'                        then rpad(o_event                     , w_event                    , ' ')
                      when 'wait_class'                   then rpad(o_wait_class                , w_wait_class               , ' ')
                      when 'state'                        then rpad(o_state                     , w_state                    , ' ')
                      when 'p1'                           then rpad(o_p1                        , w_p1                       , ' ')
                      when 'p2'                           then rpad(o_p2                        , w_p2                       , ' ')
                      when 'p3'                           then rpad(o_p3                        , w_p3                       , ' ')
                      when 'row_wait_obj#'                then rpad(o_row_wait_obj#             , w_row_wait_obj#            , ' ')
                      when 'row_wait_file#'               then rpad(o_row_wait_file#            , w_row_wait_file#           , ' ')
                      when 'row_wait_block#'              then rpad(o_row_wait_block#           , w_row_wait_block#          , ' ')
                      when 'row_wait_row#'                then rpad(o_row_wait_row#             , w_row_wait_row#            , ' ')
                      when 'blocking_session_status'      then rpad(o_blocking_session_status   , w_blocking_session_status  , ' ')
                      when 'blocking_instance'            then rpad(o_blocking_instance         , w_blocking_instance        , ' ')
                      when 'blocking_session'             then rpad(o_blocking_session          , w_blocking_session         , ' ')
                      when 'sql_hash_value'               then rpad(o_sql_hash_value            , w_sql_hash_value           , ' ')
                      when 'sql_id'                       then rpad(o_sql_id                    , w_sql_id                   , ' ')
                      when 'sql_child_number'             then rpad(o_sql_child_number          , w_sql_child_number         , ' ')
                      when 'plsql_entry_object_id'        then rpad(o_plsql_entry_object_id     , w_plsql_entry_object_id    , ' ')
                      when 'plsql_entry_subprogram_id'    then rpad(o_plsql_entry_subprogram_id , w_plsql_entry_subprogram_id, ' ')
                      when 'plsql_object_id'              then rpad(o_plsql_object_id           , w_plsql_object_id          , ' ')
                      when 'plsql_subprogram_id'          then rpad(o_plsql_subprogram_id       , w_plsql_subprogram_id      , ' ')
                      when 'module'                       then rpad(o_module                    , w_module                   , ' ')
                      when 'action'                       then rpad(o_action                    , w_action                   , ' ')
                      when 'client_identifier'            then rpad(o_client_identifier         , w_client_identifier        , ' ')
                      when 'service_name'                 then rpad(o_service_name              , w_service_name             , ' ')
                      -- aliases for convenience (only either real name or alias should be used together at the same time) 
                      when 'user'                         then rpad(o_username                  , w_username                 , ' ')
                      when 'obj'                          then rpad(o_row_wait_obj#             , w_row_wait_obj#            , ' ')
                      when 'file'                         then rpad(o_row_wait_file#            , w_row_wait_file#           , ' ')
                      when 'block'                        then rpad(o_row_wait_block#           , w_row_wait_block#          , ' ')
                      when 'row'                          then rpad(o_row_wait_row#             , w_row_wait_row#            , ' ')
                      when 'bss'                          then rpad(o_blocking_session_status   , w_blocking_session_status  , ' ')
                      when 'bsi'                          then rpad(o_blocking_instance         , w_blocking_instance        , ' ')
                      when 'bs'                           then rpad(o_blocking_session          , w_blocking_session         , ' ')
                      when 'sql'                          then rpad(o_sql_hash_value            , w_sql_hash_value           , ' ')
                      when 'sqlid'                        then rpad(o_sql_id                    , w_sql_id                   , ' ')
                      when 'child'                        then rpad(o_sql_child_number          , w_sql_child_number         , ' ')
                      when 'plsql_eoid'                   then rpad(o_plsql_entry_object_id     , w_plsql_entry_object_id    , ' ')
                      when 'plsql_esubpid'                then rpad(o_plsql_entry_subprogram_id , w_plsql_entry_subprogram_id, ' ')
                      when 'plsql_oid'                    then rpad(o_plsql_object_id           , w_plsql_object_id          , ' ')
                      when 'plsql_subpid'                 then rpad(o_plsql_subprogram_id       , w_plsql_subprogram_id      , ' ')
                      when 'mod'                          then rpad(o_module                    , w_module                   , ' ')
                      when 'act'                          then rpad(o_action                    , w_action                   , ' ')
                      when 'cid'                          then rpad(o_client_identifier         , w_client_identifier        , ' ')
                      when 'service'                      then rpad(o_service_name              , w_service_name             , ' ')
                      when 'wait_event'                   then rpad(o_event                     , w_event                    , ' ')
                      when 'wait_state'                   then rpad(o_state                     , w_state                    , ' ')
                  else
                      ''
                  end; -- case s.token

          end loop; -- ash parameter tokenizer

          output(l_output_line);

      end loop; -- grouped ash samples

  end out_ash;


-- and it begins!!!
begin

    -- get snappers own sid into g_mysid
    select sid into g_mysid from v$mystat where rownum = 1;

    pagesize := nvl( getopt('&snapper_options', 'pagesize=' ), pagesize);
    --output ( 'Pagesize='||pagesize );

    lv_ash   := getopt('&snapper_options', 'ash');
    lv_stats := getopt('&snapper_options', 'stat');

    if lv_ash is not null then gather_ash := 1; end if;
    if lv_stats is not null then gather_stats := 1; end if;

    --output('all='||case when getopt('&snapper_options', 'all') = chr(0) then 'chr(0)' when getopt('&snapper_options', 'all') is null then 'null' else (getopt('&snapper_options','all')) end);
    -- some additional default value logic
    if getopt('&snapper_options', 'all') is not null then
        output('setting stats to all due option = all');
        gather_stats := 1;
        gather_ash   := 1;
    else 
        if (lv_ash is null and lv_stats is null) then
            gather_stats := 0;  
            gather_ash   := 1;
        end if;
    end if;

    -- determine which performance counters and stats to collect
    lv_gather := case nvl( lower(getopt ('&snapper_options', 'gather=')), 'stw')
                    when 'all'  then 'stw'
                    else nvl( lower(getopt ('&snapper_options', 'gather=')), 'stw')
                 end;

    --lv_gather:=getopt ('&snapper_options', 'gather=');
    --output('lv_gather='||lv_gather);



    if pagesize > 0 then
        output(' ');
        output('-- Session Snapper v3.11 by Tanel Poder @ E2SN ( http://tech.e2sn.com )');
        output(' ');
    end if;

    -- initialize statistic and event name array
    -- fetch statistic names with their adjusted IDs
    select *
    bulk collect into sn_tmp
    from (
                                 select 'STAT' stype, statistic# - pls_adjust statistic#, name
                                 from v$statname
                                 where (lv_gather like '%s%' or lv_gather like '%a%')
                                 --
                                 union all
                                 select 'WAIT',
                                        event# + (select count(*) from v$statname) + 1 - pls_adjust, name
                                 from v$event_name
                                 where (lv_gather like '%w%' or lv_gather like '%a%')
                                 --
            &_IF_ORA10_OR_HIGHER union all
            &_IF_ORA10_OR_HIGHER select 'TIME' stype, stat_id - pls_adjust statistic#, stat_name name
            &_IF_ORA10_OR_HIGHER from v$sys_time_model
            &_IF_ORA10_OR_HIGHER where (lv_gather like '%t%' or lv_gather like '%a%')
                                 --
                                 union all
                                 select 'LATG',
                                       l.latch# +
                                           (select count(*) from v$statname) +
                                           (select count(*) from v$event_name) +
                                           1 - pls_adjust statistic#,
                                       name
                                 from v$latch l
                                 where (lv_gather like '%l%' or lv_gather like '%a%')
                                 --
            &_IF_X_ACCESSIBLE    union all
            &_IF_X_ACCESSIBLE    select 'BUFG',
            &_IF_X_ACCESSIBLE          indx +
            &_IF_X_ACCESSIBLE              (select count(*) from v$statname) +
            &_IF_X_ACCESSIBLE              (select count(*) from v$event_name) +
            &_IF_X_ACCESSIBLE              (select count(*) from v$latch) +
            &_IF_X_ACCESSIBLE              1 - pls_adjust statistic#,
            &_IF_X_ACCESSIBLE         kcbwhdes name
            &_IF_X_ACCESSIBLE    from x$kcbwh
            &_IF_X_ACCESSIBLE    where   (lv_gather like '%b%' or lv_gather like '%a%')
                                 --
                                 union all
                                 select 'ENQG',
                                       ascii(substr(e.eq_type,1,1))*256 + ascii(substr(e.eq_type,2,1)) +
                                           (select count(*) from v$statname) +
                                           (select count(*) from v$event_name) +
                                           (select count(*) from v$latch) +
            &_IF_X_ACCESSIBLE              (select count(*) from x$kcbwh) +
                                           1 - pls_adjust statistic#,
                                           eq_type
                                 from (
                                       select es.eq_type
            &_IF_ORA10_OR_HIGHER              ||' - '||lt.name
                                              eq_type,
                                              total_req#
                                       from
                                              v$enqueue_stat es
            &_IF_ORA10_OR_HIGHER            , v$lock_type lt
            &_IF_ORA10_OR_HIGHER       where es.eq_type = lt.type
                                 ) e
                                 where (lv_gather like '%e%' or lv_gather like '%a%')
    ) snapper_statnames
    order by stype, statistic#;

    -- store these into an index_by array organized by statistic# for fast lookup
    --output('sn_tmp.count='||sn_tmp.count);
    --output('lv_gather='||lv_gather);
    for i in 1..sn_tmp.count loop
    --  output('i='||i||' statistic#='||sn_tmp(i).statistic#);
        sn(sn_tmp(i).statistic#) := sn_tmp(i);
    end loop;


    -- main sampling loop
    for c in 1..&snapper_count loop

        -- sesstat and other performance counter sampling
        if gather_stats = 1 then

            -- print header if required
            gv_header_string :=
                      CASE WHEN output_header   = 1 THEN 'HEAD,'                        END
                   || CASE WHEN output_sid      = 1 THEN '    SID,'                     END
                   || CASE WHEN output_username = 1 THEN ' USERNAME  ,'                 END
                   || CASE WHEN output_time     = 1 THEN ' SNAPSHOT START   ,'          END
                   || CASE WHEN output_seconds  = 1 THEN '  SECONDS,'                   END
                   || CASE WHEN output_stype    = 1 THEN ' TYPE,'                       END
                   || CASE WHEN output_sname    = 1 THEN rpad(' STATISTIC',41,' ')||',' END
                   || CASE WHEN output_delta    = 1 THEN '         DELTA,'              END
                   || CASE WHEN output_delta_s  = 1 THEN '  DELTA/SEC,'                 END
                   || CASE WHEN output_hdelta   = 1 THEN '     HDELTA,'                 END
                   || CASE WHEN output_hdelta_s = 1 THEN ' HDELTA/SEC,'                 END
                   || CASE WHEN output_percent  = 1 THEN '    %TIME,'                   END
                   || CASE WHEN output_pcthist  = 1 THEN ' GRAPH       '                END
            ;


            if pagesize > 0 and mod(c-1, pagesize) = 0 then
                output(rpad('-',length(gv_header_string),'-'));
                output(gv_header_string);
                output(rpad('-',length(gv_header_string),'-'));
            else
                if pagesize = -1 and c = 1 then

                    output(gv_header_string);

                end if;
            end if;


            if c = 1 then

                get_sessions;
                snap(d1,s1);

            else

                get_sessions;
                d1 := d2;
                s1 := s2;

            end if; -- c = 1

            -- output('snapper_sleep='||to_char(&snapper_sleep - (sysdate - d1)*86400));
            -- dbms_lock.sleep( (&snapper_sleep - (sysdate - d1)) );
            -- dbms_lock.sleep( (&snapper_sleep - (sysdate - d1))*1000/1024 );

        end if; -- gather_stats = 1



        -- ASH style sampling 
        ash_date1 := sysdate; 

        if gather_ash = 1 then 
            while sysdate < (ash_date1 + (&snapper_sleep/86400)) loop
               -- get active session records from g_sessions
               get_sessions;
               extract_ash();
               -- sleep timeout backoff depending on the duration sampled (for up to 10 seconds total sampling time will get max 100 Hz sampling)
               -- for longer duration sampling the algorithm will back off and for long durations (over 100 sec) the sampling rate will stabilize
               -- at 1Hz
               dbms_lock.sleep( greatest(0.1,(least(1,&snapper_sleep*&snapper_count/100))) );
            end loop;

        else
            dbms_lock.sleep( ((ash_date1+(&snapper_sleep/86400)) - sysdate)*86400 ); 
        end if;

        ash_date2 := sysdate; 

        -- sesstat new sample and delta calculation
        if gather_stats = 1 then

            get_sessions;
            snap(d2,s2);

            -- manually coded nested loop outer join for calculating deltas
            -- why not use a SQL join? this would require creation of PL/SQL 
            -- collection object types, but Snapper does not require any changes 
            -- to the database, so any custom object types are out! 
            changed_values := 0;
            missing_values_s1 := 0;
            missing_values_s2 := 0;

            -- remember last disappeared SID so we woudlnt need to output a warning 
            -- message for each statistic row of that disappeared sid 
            disappeared_sid := 0;

            i :=1; -- iteration counter (for debugging)
            a :=1; -- s1 array index
            b :=1; -- s2 array index

            while ( a <= s1.count and b <= s2.count ) loop

                delta := 0; -- don't print

                case
                    when s1(a).sid = s2(b).sid then

                        case
                            when s1(a).statistic# = s2(b).statistic# then

                                delta := s2(b).value - s1(a).value;
                                if delta != 0 then fout(); end if;

                                a := a + 1;
                                b := b + 1;

                            when s1(a).statistic# > s2(b).statistic# then

                                delta := s2(b).value;
                                if delta != 0 then fout(); end if;

                                b := b + 1;

                            when s1(a).statistic# < s2(b).statistic# then

                                output('ERROR, s1(a).statistic# < s2(b).statistic#, a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count);
                                a := a + 1;
                                b := b + 1;

                        else
                                output('ERROR, s1(a).statistic# ? s2(b).statistic#, a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count);
                                a := a + 1;
                                b := b + 1;

                        end case; -- s1(a).statistic# ... s2(b).statistic#

                    when s1(a).sid > s2(b).sid then

                        delta := s2(b).value;
                        if delta != 0 then fout(); end if;

                        b := b + 1;

                    when s1(a).sid < s2(b).sid then

                        if disappeared_sid != s2(b).sid then
                            output('WARN, Session has disappeared during snapshot, ignoring SID='||to_char(s2(b).sid)||' debug(a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count||')');
                        end if;
                        disappeared_sid := s2(b).sid;                    
                        a := a + 1;

                    else
                        output('ERROR, Should not be here, SID='||to_char(s2(b).sid)||' a='||to_char(a)||' b='||to_char(b)||' s1.count='||s1.count||' s2.count='||s2.count||' s2.count='||s2.count);

                end case; -- s1(a).sid ... s2(b).sid

                i:=i+1;

                if  delta != 0 then

                    changed_values := changed_values + 1;

                end if; -- delta != 0

            end loop; -- while ( a <= s1.count and b <= s2.count )

            if pagesize > 0 and changed_values > 0 then 
                output('--  End of Stats snap '||to_char(c)||', end='||to_char(d2, 'YYYY-MM-DD HH24:MI:SS')||', seconds='||to_char(case (d2-d1) when 0 then &snapper_sleep else round((d2-d1) * 86400, 1) end)); 
                output(''); 
            end if;

            output(' ');

        end if; -- gather_stats = 1

        if gather_ash = 1 then

            -- get ASH sample grouping details
            g_ash_columns  := nvl( getopt('&snapper_options', 'ash='  ), g_ash_columns  );

            -- optional additional ASH groupings
            g_ash_columns1 := case when getopt('&snapper_options', 'ash1' ) is null then null when getopt('&snapper_options', 'ash1' ) = chr(0) then g_ash_columns1 else getopt('&snapper_options', 'ash1=' ) end;
            g_ash_columns2 := case when getopt('&snapper_options', 'ash2' ) is null then null when getopt('&snapper_options', 'ash2' ) = chr(0) then g_ash_columns2 else getopt('&snapper_options', 'ash2=' ) end;
            g_ash_columns3 := case when getopt('&snapper_options', 'ash3' ) is null then null when getopt('&snapper_options', 'ash3' ) = chr(0) then g_ash_columns3 else getopt('&snapper_options', 'ash3=' ) end;

            -- group ASH records and print report
            out_ash( g_ash_columns, 10 );
            -- group and print optional ASH reports
            if g_ash_columns1 is not null then out_ash( g_ash_columns1, 10 ); end if;
            if g_ash_columns2 is not null then out_ash( g_ash_columns2, 10 ); end if;
            if g_ash_columns3 is not null then out_ash( g_ash_columns3, 10 ); end if;


            if pagesize > 0 then 
                output(' '); 
                output('--  End of ASH snap '||to_char(c)||', end='||to_char(ash_date2, 'YYYY-MM-DD HH24:MI:SS')||', seconds='||to_char(case (ash_date2-ash_date1) when 0 then &snapper_sleep else round((ash_date2-ash_date1) * 86400, 1) end)||', samples_taken='||g_ash_samples_taken); 
                output(' '); 
            end if;

            reset_ash();

        end if; -- gather_ash = 1

    end loop; -- for c in 1..snapper_count

end;
/

undefine snapper_oraversion
undefine snapper_sleep
undefine snapper_count
undefine snapper_sid
undefine ssid_begin
-- undefine _IF_ORA10_OR_HIGHER
-- undefine _IF_ORA9
-- undefine _IF_ORA11_OR_HIGHER
-- undefine _IF_LOWER_THAN_ORA11
-- undefine _NO_BLK_INST
-- undefine _YES_BLK_INST
-- undefine _NO_PLSQL_OBJ_ID
-- undefine _YES_PLSQL_OBJ_ID
-- undefine _IF_DBMS_SYSTEM_ACCESSIBLE
-- undefine _IF_X_ACCESSIBLE
col snapper_ora10higher clear
col snapper_ora11higher clear
col snapper_ora11lower  clear
col dbms_system_accessible clear

set serverout off

