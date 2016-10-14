select /* semi big */ object_name 
  from kso.big
 where exists ( select /*+ semijoin */ null from kso.small where small.object_id = big.object_id );

select /* semi intersect */ object_name 
  from kso.big
intersect
 select object_name from kso.small 
/


