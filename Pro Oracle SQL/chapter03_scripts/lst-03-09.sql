/* Listing 3-9 */

select t.table_name||'.'||i.index_name idx_name,
i.clustering_factor, t.blocks, t.num_rows
from all_indexes i, all_tables t
where i.table_name = t.table_name
and t.table_name = 'EMPLOYEES'
and t.owner = 'HR'
and i.index_name = 'EMP_DEPARTMENT_IX'
order by t.table_name, i.index_name;

select department_id, last_name, blk_no,
lag (blk_no,1,blk_no) over (order by department_id) prev_blk_no,
case when blk_no != lag (blk_no,1,blk_no) over (order by department_id)
or rownum = 1
then '*** +1'
else null
end cluf_ct
from (
select department_id, last_name,
dbms_rowid.rowid_block_number(rowid) blk_no
from hr.employees
where department_id is not null
order by department_id
);

