/* Listing 6-6 */

select id, parent_id, operation
from (
select level lvl, id, parent_id, lpad(' ',level) || operation || ' ' || options
|| ' ' || object_name as operation
from plan_table
start with id = 0
connect by prior id = parent_id
)
order by lvl desc, id;

