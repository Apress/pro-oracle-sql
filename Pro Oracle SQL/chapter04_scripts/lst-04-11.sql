/* Listing 4-11 */


select count(*) row_ct, count(comm) comm_ct,
avg(comm) avg_comm, min(comm) min_comm,
max(comm) max_comm, sum(comm) sum_comm
from scott.emp ;
