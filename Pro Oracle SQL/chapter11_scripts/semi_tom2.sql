select count(created)
  from big
 where object_id in ( select object_id from small );

select count(created)
  from big
 where exists ( select null from small where small.object_id = big.object_id );

select count(created)
  from small
 where exists ( select null from big where small.object_id = big.object_id );

select count(created)
  from small
 where object_id in ( select object_id from big );

