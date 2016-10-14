PROMPT 
PROMPT Distribution
PROMPT

select dbms_rowid.rowid_object(rowid), count(*) from sales_fact_part
group by dbms_rowid.rowid_object(rowid);

