PROMPT
PROMPT MODEL clause -- Reference example
PROMPT     
PROMPT  
  col product format A12
  col country format A10
  col region format A10
  col year format 9999
  col week format 99
  col sale format 999999.99
  col receipts format 999999.99
  set lines 120 pages 100
    select year, week,sale, prod_list_price, iso_code
      from sales_fact
      where country in ('Australia') and product ='Xtend Memory'
      model return updated rows
      REFERENCE ref_prod on
        (select prod_name, max(prod_list_price) prod_list_price from 
		products group by prod_name)
         dimension by (prod_name)
         measures (prod_list_price)
      REFERENCE ref_country on
        (select country_name, country_iso_code from countries)
         dimension by (country_name )
         measures (country_iso_code)
      MAIN main_section
        partition by (product, country)
        dimension by (year, week)
        measures ( sale, receipts, 0 prod_list_price ,
				 cast(' ' as varchar2(5)) iso_code)
        rules   (
            prod_list_price[year,week] order by year, week = 
				ref_prod.prod_list_price [ cv(product) ],
	    iso_code [year, week] order by year, week =  
				ref_country.country_iso_code [ cv(country)]
	   )
  order by year, week
/

