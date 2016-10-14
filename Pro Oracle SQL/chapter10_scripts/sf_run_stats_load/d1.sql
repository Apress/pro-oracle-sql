select 
	dummy
	, ( select dummy from dual d where d.dummy = d1.dummy)
from dual d1
/
