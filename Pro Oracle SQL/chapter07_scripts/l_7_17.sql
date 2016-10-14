
-- demo bit vector created by grouping_id()

col gid format 999 head 'GID'
col gb_0 format 9999999 head 'GROUPING|BIT 0'
col gb_1 format 9999999 head 'GROUPING|BIT 1'

col bit_vector head 'BIT|VECTOR' format a6

with rowgen as (
  select 1 bit_1, 0 bit_0
  from dual 
),
cubed as (
  select 
    grouping_id(bit_1,bit_0) gid
    , to_char(grouping(bit_1)) bv_1
    , to_char(grouping(bit_0)) bv_0
    , decode(grouping(bit_1),1,'GRP BIT 1') gb_1
    , decode(grouping(bit_0),1,'GRP BIT 0') gb_0
  from rowgen
  group by cube(bit_1,bit_0)
)
select 
  gid
  , bv_1 || bv_0 bit_vector
  , gb_1
  , gb_0
from cubed
order by gid

l

/

