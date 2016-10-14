col search_condition for a40
select table_name,constraint_name,constraint_type, search_condition, status
from dba_constraints
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
and constraint_type like nvl('&constraint_type',constraint_type)
/
