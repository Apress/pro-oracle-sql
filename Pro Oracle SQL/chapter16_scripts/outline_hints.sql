select name, hint from dba_outline_hints
where name like nvl('&name',name)
and upper(hint) like upper(nvl('&hint',hint))
/
