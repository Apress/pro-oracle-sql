PROMPT
PROMPT FACT table creation.
PROMPT

drop table sales_fact;
CREATE table sales_fact AS 
SELECT  country_name country,country_subRegion region, prod_name product, calendar_year year, calendar_week_number week, 
SUM(amount_sold) sale, 
sum(amount_sold*
  ( case   
         when mod(rownum, 10)=0 then 1.4
         when mod(rownum, 5)=0 then 0.6
         when mod(rownum, 2)=0 then 0.9
         when mod(rownum,2)=1 then 1.2
         else 1
    end )) receipts
FROM sales, times, customers, countries, products
WHERE sales.time_id = times.time_id AND
sales.prod_id = products.prod_id AND
sales.cust_id = customers.cust_id AND
customers.country_id = countries.country_id
GROUP BY 
country_name,country_subRegion, prod_name, calendar_year, calendar_week_number; 