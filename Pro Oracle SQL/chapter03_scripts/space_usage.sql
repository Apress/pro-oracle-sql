-- space_usage.sql

declare
	l_tabname varchar2(30) := '&1';
	l_fs1_bytes number;
	l_fs2_bytes number;
	l_fs3_bytes number;
	l_fs4_bytes number;
	l_fs1_blocks number;
	l_fs2_blocks number;
	l_fs3_blocks number;
	l_fs4_blocks number;
	l_full_bytes number;
	l_full_blocks number;
	l_unformatted_bytes number;
	l_unformatted_blocks number;
begin
	dbms_space.space_usage(
			segment_owner => user,
			segment_name => l_tabname,
			segment_type => 'TABLE',
			fs1_bytes => l_fs1_bytes,
			fs1_blocks => l_fs1_blocks,
			fs2_bytes => l_fs2_bytes,
			fs2_blocks => l_fs2_blocks,
			fs3_bytes => l_fs3_bytes,
			fs3_blocks => l_fs3_blocks,
			fs4_bytes => l_fs4_bytes,
			fs4_blocks => l_fs4_blocks,
			full_bytes => l_full_bytes,
			full_blocks => l_full_blocks,
			unformatted_blocks => l_unformatted_blocks,
			unformatted_bytes => l_unformatted_bytes
			);
	dbms_output.put_line('0-25% Free = '||l_fs1_blocks||' Bytes = '||l_fs1_bytes);
	dbms_output.put_line('25-50% Free = '||l_fs2_blocks||' Bytes = '||l_fs2_bytes);
	dbms_output.put_line('50-75% Free = '||l_fs3_blocks||' Bytes = '||l_fs3_bytes);
	dbms_output.put_line('75-100% Free = '||l_fs4_blocks||' Bytes = '||l_fs4_bytes);
	dbms_output.put_line('Full Blocks = '||l_full_blocks||' Bytes = '||l_full_bytes);
end;
/
