

with counts as (
  select 
    count(distinct first_name) first_name_count
    , count(distinct last_name) last_name_count
    , count(distinct(first_name||last_name)) full_name_count
  from hr.employees
)
select 
  first_name_count
  , last_name_count
  , full_name_count
  , first_name_count + last_name_count + full_name_count + 1 total_count
from counts

l

/