/* Listing 6-7 */

select /* recentsql */ sql_id, child_number, hash_value, address, executions, sql_text
from v$sql
where parsing_user_id = (select user_id
from all_users
where username = 'SCOTT')
and command_type in (2,3,6,7,189)
and UPPER(sql_text) not like UPPER('%recentsql%')
/
