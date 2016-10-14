PROMPT
PROMPT MODEL clause -- Iteration and presentv example
PROMPT     
PROMPT  
  col product format A12
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  col sale_list format A40
  set lines 120 pages 100
   select year, week,sale, sale_list
      from sales_fact
      where country in ('Australia') and product ='Xtend Memory'
      model return updated rows
      partition by (product, country)
      dimension by (year, week)
      measures ( cast(' ' as varchar2(120) ) sale_list, sale, 0 tmp)
      rules  iterate (5) (
               sale_list [ year, week ] order by year, week =
		   presentv( sale [cv(year), CV(week)-iteration_number + 2 ],
			sale [cv(year), CV(week)-iteration_number +2 ]          ||
                        case when iteration_number=0 then '' else ', ' end  ||
                        sale_list [cv(year) ,cv(week)]  ,
		        sale_list [cv(year) ,cv(week)] )
   )
    order by year, week
/

