PROMPT 
PROMPT Dynamic SQL
PROMPT
col year format 9999
col week format 99
col sale format 999999.99
set lines 120 pages 100
set  serveroutput on 
create or replace procedure  
  analytic_dynamic_prc ( part_col_string varchar2, v_country varchar2, v_product varchar2)
is 
  type numtab is table of number(18,2) index by binary_integer;
  l_year numtab;
  l_week numtab;
  l_sale numtab;
  l_rank numtab;
  l_sql_string  varchar2(512) ;
begin
 l_sql_String := 
 'select * from (
   select  year, week,sale, 
    rank() over(
          partition by ' ||part_col_string ||'
          order by sale desc
           ) sales_rank
   from sales_fact
   where country in (' ||chr(39) || v_country || chr(39) || ' )  and 
         product =' || chr(39) || v_product || chr(39) ||
       ' order by product, country,year, week
    ) where sales_rank<=10
    order by 1,4';
 execute immediate l_sql_string bulk collect into  l_year, l_week, l_sale, l_rank;
 for  i  in 1 .. l_year.count
  loop
       dbms_output.put_line ( l_year(i) ||' |' || l_week (i) ||
                            '|'|| l_sale(i) || '|' || l_rank(i) ); 
  end loop;
 end;
/

exec analytic_dynamic_prc ( 'product, country, region','Australia','Xtend Memory');
exec analytic_dynamic_prc ( 'product, country,region, year','Australia','Xtend Memory');