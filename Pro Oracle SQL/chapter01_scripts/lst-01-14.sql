/* Listing 1-14 */

select  c.customer_id, c.cust_first_name||' '||c.cust_last_name,
		(select e.last_name 
		 from hr.employees e 
		 where e.employee_id = c.account_mgr_id) acct_mgr
from oe.customers c;

