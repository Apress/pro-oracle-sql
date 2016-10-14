select owner, table_name, stats_update_time
from DBA_TAB_STATS_HISTORY
where owner like nvl('&owner',owner)
and table_name like nvl('&table_name',table_name)
/
