col child format 99999
col name for a40
col value for a40
select * from (
select 
-- INST_ID,                    
--        KQLFSQCE_PHAD,              
--        KQLFSQCE_HASH,   
KQLFSQCE_SQLID sql_id,             
--        KQLFSQCE_HADD,              
        KQLFSQCE_CHNO child,              
--        KQLFSQCE_PNUM,              
        KQLFSQCE_PNAME name,             
        KQLFSQCE_PVALUE value,
        decode(bitand(KQLFSQCE_FLAGS, 2), 0, 'NO', 'YES') isdefault
from   X$KQLFSQCE                                 
-- where  bitand(KQLFSQCE_FLAGS, 8) = 0                             
-- and  (bitand(KQLFSQCE_FLAGS, 4) = 0 or bitand(KQLFSQCE_FLAGS, 2) = 0)
where  KQLFSQCE_SQLID like nvl('&sql_id',KQLFSQCE_SQLID)
and decode(bitand(KQLFSQCE_FLAGS, 2), 0, 'NO', 'YES') like nvl('&isdefault','%')
)
order by 1,2 asc,decode(substr(name,1,1),'_',2,1), replace(name,'_','')
/
