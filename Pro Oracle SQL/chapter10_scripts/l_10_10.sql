
set linesize 200
set serveroutput off
set timing on

col cust_id format 99999999 head 'CUST ID'
col prod_category format a30 head 'PRODUCT CATEGORY'
col cust_first_name format a15 head 'FIRST NAME'
col cust_last_name format a15 head 'LAST NAME'
col total_sale format 999,999,999.90 head 'TOTAL SALE'

break on report
compute sum of total_sale on report

drop table cust3year;
drop table sales3year;

-- set term off

spool l_10_10.txt

set echo on 

create global temporary table cust3year ( cust_id number );

create global temporary table sales3year( 
	cust_id number ,
	prod_category varchar2(50),
	total_sale number
)
/

begin
	execute immediate 'truncate table cust3year';
	execute immediate 'truncate table sales3year';
	
	insert into cust3year
	select cust_id --, count(cust_years) year_count
	from (
		select distinct cust_id, trunc(time_id,'YEAR') cust_years
		from sh.sales
	)
	group by cust_id
	having count(cust_years) >= 3;

	for crec in ( select cust_id from cust3year)
	loop
		insert into sales3year
		select s.cust_id,p.prod_category, sum(co.unit_price * s.quantity_sold)
		from sh.sales s
		join sh.products p on p.prod_id = s.prod_id
		join sh.costs co on co.prod_id = s.prod_id
		        and co.time_id = s.time_id
		join sh.customers cu on cu.cust_id = s.cust_id
		where s.cust_id = crec.cust_id
		group by s.cust_id, p.prod_category;
	end loop;
end;
/

set echo off term off

select c3.cust_id, c.cust_last_name, c.cust_first_name, s.prod_category, s.total_sale
from cust3year c3
join sales3year s on s.cust_id = c3.cust_id
join sh.customers c on c.cust_id = c3.cust_id
order by 1,4

l

/

spool off

set term on

