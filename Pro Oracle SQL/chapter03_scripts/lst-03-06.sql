/* Listing 3-6 */

select blocks from user_segments where segment_name = 'T2';

select count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct from t2 ;

select min(dbms_rowid.rowid_block_number(rowid)) min_blk,
max(dbms_rowid.rowid_block_number(rowid)) max_blk from t2 ;

get space_usage.sql

@space_usage T2

delete from t2 ;

commit ;

@space_usage T2

select blocks from user_segments where segment_name = 'T2';

select count(distinct (dbms_rowid.rowid_block_number(rowid))) block_ct from t2 ;

set autotrace traceonly

select * from t2 ;

set autotrace off

truncate table t2 ;

@space_usage T2

select blocks from user_segments where segment_name = 'T2';

set autotrace traceonly

select * from t2 ;

set autotrace off
