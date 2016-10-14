rem
rem Displays column information
rem


declare
	v_owner varchar2(30) := upper('&p_owner');
	v_table varchar2(30) := upper('&p_table');
	v_ct            number ;

	v_max_colname   number ;
	v_max_ndv       number ;
	v_max_nulls     number ;
	v_max_bkts      number ;
	v_max_smpl      number ;
	v_max_endnum    number ;
	v_max_endval    number ;
	prev_col        varchar2(30) ;

	cn     number;
	cv     varchar2(70);
	cd     date;
	cnv    nvarchar2(70);
	cr     rowid;
	cc     char(70);

	cn1     number;
	cv1     varchar2(32);
	cd1     date;
	cnv1    nvarchar2(32);
	cr1     rowid;
	cc1     char(32);

	cn2     number;
	cv2     varchar2(32);
	cd2     date;
	cnv2    nvarchar2(32);
	cr2     rowid;
	cc2     char(32);
   
	cursor col_stats is
	select a.column_name,
		a.last_analyzed,
		a.nullable,
		a.num_distinct, a.density, a.num_nulls,
		--a.histogram, 
		a.num_buckets, a.avg_col_len, a.sample_size,
		a.low_value, a.high_value, a.data_type
	from all_tab_cols a
	where a.owner = v_owner
	and a.table_name = v_table 
	order by a.column_name;


begin

  select max(length(column_name)) + 1, max(length(num_distinct)) + 3,
         max(length(num_nulls)) + 1, max(length(num_buckets)) + 1,
         max(length(sample_size)) + 1
    into v_max_colname, v_max_ndv, v_max_nulls, v_max_bkts, v_max_smpl
    from all_tab_cols
   where owner = v_owner
     and table_name = v_table ;

  if v_max_nulls < 8 then
     v_max_nulls := 8 ;
  end if ;

  if v_max_bkts < 10 then
     v_max_bkts := 10 ;
  end if ;

  if v_max_smpl < 7 then
     v_max_smpl := 7;
  end if;


  dbms_output.put_line('');
  dbms_output.put_line('===================================================================================================================================');
  dbms_output.put_line('  COLUMN STATISTICS');
  dbms_output.put_line('===================================================================================================================================');
  dbms_output.put_line(' ' || rpad('Name',v_max_colname) || ' Analyzed             Null? ' ||
        rpad(' NDV',v_max_ndv) || '  ' || rpad(' Density',10) ||
        rpad('# Nulls',v_max_nulls) || '  ' || rpad('# Buckets',v_max_bkts) || '  ' ||
        rpad('Sample',v_max_smpl) || '  AvgLen  Lo-Hi Values');
  dbms_output.put_line('===================================================================================================================================');


  for v_rec in col_stats loop
      if v_rec.last_analyzed is not null then
          if v_rec.data_type = 'NUMBER' then 
             dbms_stats.convert_raw_value(v_rec.low_value, cn1);
             dbms_stats.convert_raw_value(v_rec.high_value, cn2);
	     cv := cn1 || ' | ' || cn2;
	   elsif (v_rec.data_type = 'VARCHAR2') then
             dbms_stats.convert_raw_value(v_rec.low_value, cv1);
             dbms_stats.convert_raw_value(v_rec.high_value, cv2);
	     cv := substr(trim(cv1),1,30) || ' | ' || substr(trim(cv2),1,30);
	   elsif (v_rec.data_type = 'DATE') then
             dbms_stats.convert_raw_value(v_rec.low_value, cd1);
             dbms_stats.convert_raw_value(v_rec.high_value, cd2);
	     cv := to_char(cd1,'mm/dd/yyyy hh24:mi:ss') || ' | ' || to_char(cd2,'mm/dd/yyyy hh24:mi:ss');
	   elsif (v_rec.data_type = 'NVARCHAR2') then
             dbms_stats.convert_raw_value(v_rec.low_value, cnv1);
             dbms_stats.convert_raw_value(v_rec.high_value, cnv2);
	     cv := substr(trim(to_char(cnv1)),1,30) || ' | ' || substr(trim(to_char(cnv2)),1,30);
	   elsif (v_rec.data_type = 'ROWID') then
             dbms_stats.convert_raw_value(v_rec.low_value, cr1);
             dbms_stats.convert_raw_value(v_rec.high_value, cr2);
	     cv := substr(trim(to_char(cr1)),1,30) || ' | ' || substr(trim(to_char(cr2)),1,30);
	   elsif (v_rec.data_type = 'CHAR') then
             dbms_stats.convert_raw_value(v_rec.low_value, cc1);
             dbms_stats.convert_raw_value(v_rec.high_value, cc2);
	     cv := substr(trim(cc1),1,30) || ' | ' || substr(trim(cc2),1,30);
	   else
	     cv:= 'UNKNOWN DATATYPE';
	   end if;
          
          dbms_output.put_line(rpad(lower(v_rec.column_name),v_max_colname) || '  ' ||
          v_rec.last_analyzed || '  ' ||
          rpad(v_rec.nullable,5) || '  ' ||
          rpad(v_rec.num_distinct,v_max_ndv) ||
          to_char(v_rec.density,'9.999999') || '  ' ||
          rpad(v_rec.num_nulls,v_max_nulls) || '  ' ||
          rpad(v_rec.num_buckets,v_max_bkts) || '  ' ||
          rpad(v_rec.sample_size,v_max_smpl) || '  ' ||
          rpad(v_rec.avg_col_len,9) || '  ' || rpad(cv,70));
      else
          dbms_output.put_line(rpad(lower(v_rec.column_name),v_max_colname));
      end if;
  end loop ;
end;
/
