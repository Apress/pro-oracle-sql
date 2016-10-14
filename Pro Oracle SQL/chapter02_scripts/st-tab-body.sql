rem
rem Displays table information
rem


declare
	v_owner varchar2(30) := upper('&p_owner');
	v_table varchar2(30) := upper('&p_table');
	
	cursor tabs is
	select *
	from all_tables
	where table_name = UPPER(v_table)
	and owner = UPPER(v_owner) ;


begin
    dbms_output.put_line('===================================================================================================================================');
    dbms_output.put_line('  TABLE STATISTICS');
    dbms_output.put_line('===================================================================================================================================');


      for tabinfo in tabs loop
        dbms_output.put_line ('Owner         : ' || lower(tabinfo.owner)) ;
        dbms_output.put_line ('Table name    : ' || lower(tabinfo.table_name)) ;
        dbms_output.put_line ('Tablespace    : ' || lower(tabinfo.tablespace_name)) ;
        dbms_output.put_line ('Cluster name  : ' || lower(tabinfo.cluster_name)) ;
        dbms_output.put_line ('Partitioned   : ' || lower(tabinfo.partitioned)) ;
        dbms_output.put_line ('Last analyzed : ' || tabinfo.last_analyzed) ;
        dbms_output.put_line ('Sample size   : ' || tabinfo.sample_size) ;
        dbms_output.put_line ('Degree        : ' || to_number(tabinfo.degree)) ;
        dbms_output.put_line ('IOT Type      : ' || lower(tabinfo.iot_type)) ;
        dbms_output.put_line ('IOT name      : ' || lower(tabinfo.iot_name)) ;
        dbms_output.put_line ('# Rows        : ' || tabinfo.num_rows) ;
        dbms_output.put_line ('# Blocks      : ' || tabinfo.blocks ) ;
        dbms_output.put_line ('Empty Blocks  : ' || tabinfo.empty_blocks) ;
        dbms_output.put_line ('Avg Space     : ' || tabinfo.avg_space) ;
        dbms_output.put_line ('Avg Row Length: ' || tabinfo.avg_row_len ) ;
        dbms_output.put_line ('Monitoring?   : ' || lower(tabinfo.monitoring )) ;
--        dbms_output.put_line ('Status        : ' || lower(tabinfo.status )) ;
        
      end loop;
end;
/
