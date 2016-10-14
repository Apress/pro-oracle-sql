
truncate table results;

insert into results( child_count, name, run1, run2, diff)
select to_number('&&child_count') child_count, a.name name, b.value-a.value run1, c.value-b.value run2,
	( (c.value-b.value)-(b.value-a.value)) diff
from run_stats a, run_stats b, run_stats c
where a.name = b.name
	and b.name = c.name
	and a.runid = 'before'
	and b.runid = 'after 1'
	and c.runid = 'after 2'
	and (c.value-a.value) > 0
	and (c.value-b.value) <> (b.value-a.value)
order by abs( (c.value-b.value)-(b.value-a.value))
/

commit;

