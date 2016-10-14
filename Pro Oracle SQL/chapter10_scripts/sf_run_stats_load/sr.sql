
@clears

set line 200

select name, child_count, run1, run2, diff
from results
where abs(decode(least(run1,run2),0,.0001, least(run1,run2)) / greatest(run1,run2) ) < .1
and abs(diff) > 100
order by abs(diff)
/

