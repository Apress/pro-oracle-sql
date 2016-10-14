--- Invalid Objects Unit Test and Object Recompile

select object_name, 
       object_type,
       last_ddl_time,
       status
  from user_objects
 where status != 'VALID';

alter function GET_LISTPRICE compile ; 

alter procedure GET_ORDER_TOTAL compile ; 

select object_name, 
       object_type,
       last_ddl_time,
       status
  from user_objects
 where status != 'VALID';

