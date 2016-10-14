/* Listing 6-3 */

select id, parent_id,
lpad(' ',level) || operation || ' ' || options || ' ' ||
object_name as operation
from plan_table
start with id = 0
connect by prior id = parent_id ;

