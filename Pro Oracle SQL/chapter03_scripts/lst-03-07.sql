/* Listing 3-7 */

column filen format a50 head 'File Name'

select e.rowid ,
(select file_name
from dba_data_files
where file_id = dbms_rowid.rowid_to_absolute_fno(e.rowid, user, 'EMP')) filen,
dbms_rowid.rowid_block_number(e.rowid) block_no,
dbms_rowid.rowid_row_number(e.rowid) row_no
from emp e
where e.ename = 'KING' ;
