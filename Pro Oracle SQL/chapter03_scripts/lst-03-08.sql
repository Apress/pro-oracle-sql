/* Listing 3-8 */

select t.table_name||'.'||i.index_name idx_name,
i.clustering_factor, t.blocks, t.num_rows
from user_indexes i, user_tables t
where i.table_name = t.table_name
and t.table_name in ('T1','T2')
order by t.table_name, i.index_name;

