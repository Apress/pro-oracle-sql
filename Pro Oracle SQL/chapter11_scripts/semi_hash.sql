select /* semi */ /*+ hash_sj */ count(*)
  from kso.big
 where object_id in ( select /*+ hash_sj */ object_id from kso.small );

select /* semi */ /*+ hash_sj */ count(*)
  from kso.big
 where exists ( select /*+ hash_sj */ null from kso.small where small.object_id = big.object_id );

select /* semi */ /*+ hash_sj */ count(*)
  from kso.small
 where exists ( select /*+ hash_sj */ null from kso.big where small.object_id = big.object_id );

select /* semi */ /*+ hash_sj */ count(*)
  from kso.small
 where object_id in ( select /*+ hash_sj */ object_id from kso.big );
