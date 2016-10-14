select object_name, object_type, last_ddl_time, status  from user_objects
 where status != 'VALID';
