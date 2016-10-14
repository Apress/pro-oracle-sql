rem
rem Displays histogram information
rem


declare
	v_owner varchar2(30) := upper('&p_owner');
	v_table varchar2(30) := upper('&p_table');
	v_ct            number ;
	prev_col        varchar2(30) ;

	cursor hist_stats (col_nm all_tab_histograms.column_name%TYPE) is
	select rownum bucket, pct_total||'%' hist_line
	-- lpad('+', pct_total, '+')||'('||pct_total||'%)' hist_line
	from
	(
	select endpoint_number curr_ep, 
	       lag(endpoint_number,1,0) over(order by endpoint_number) prev_ep, 
	       (endpoint_number - lag(endpoint_number,1,0) over (order by endpoint_number)) num_in_bkt,
	       max(endpoint_number) over () last_ep,
	       round((endpoint_number - lag(endpoint_number,1,0) over (order by endpoint_number)) / max(endpoint_number) over (), 2) * 100 pct_total,
	       row_number() over (order by endpoint_number) rn
	  from all_tab_histograms
	 where owner = v_owner
	   and table_name = v_table
	   and column_name = col_nm
	   and EXISTS (select null from all_tab_cols 
			where column_name = col_nm and table_name = v_table and owner = v_owner and num_buckets > 1)
	)
	where pct_total > 5;

	cursor cols is
	select *
	from all_tab_cols
	where table_name = UPPER(v_table)
	and owner = UPPER(v_owner) ;

begin

  select count(1)
    into v_ct
    from all_tab_histograms b
   where b.owner = v_owner
     and b.table_name = v_table
     and (exists (select 1 from all_tab_columns
                   where num_buckets > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
          or
          exists (select 1 from all_tab_histograms
                   where endpoint_number > 1
                     and owner = b.owner
                     and table_name = b.table_name
                     and column_name = b.column_name)
         );

  if v_ct > 0 then
      
      v_ct := 0 ;
      for v_rec in cols loop 		
          if v_rec.num_buckets > 1 then 
	     for v_hist_rec in hist_stats (v_rec.column_name) loop
          
		  if v_ct = 0 then
		     v_ct := 1 ;
		     prev_col := v_rec.column_name ;
		     dbms_output.put_line('');  
		     dbms_output.put_line('===================================================================================================================================');
		     dbms_output.put_line('  HISTOGRAM STATISTICS     Note: Only columns with buckets containing > 5% of total values are shown.');
		     dbms_output.put_line('===================================================================================================================================');
      		     dbms_output.put_line('');
		     dbms_output.put_line(v_rec.column_name||' (' || v_rec.num_buckets || ' buckets)');
		  elsif prev_col <> v_rec.column_name then
		     dbms_output.put_line('');
		     dbms_output.put_line(v_rec.column_name||' (' || v_rec.num_buckets || ' buckets)');
		     prev_col := v_rec.column_name ;
		  end if ;

		  dbms_output.put_line(v_hist_rec.bucket||' '||v_hist_rec.hist_line);
	     end loop;
	  end if;
      end loop ;
      dbms_output.put_line('');
  end if ;
end;
/
