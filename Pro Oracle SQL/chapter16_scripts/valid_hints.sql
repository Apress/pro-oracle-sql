select name,version from v$sql_hint
where upper(name) like '%'||upper(nvl('&hint',name))||'%'
order by name;
