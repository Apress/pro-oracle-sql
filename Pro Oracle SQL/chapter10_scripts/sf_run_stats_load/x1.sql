select /*+ gather_plan_statistics */
   p.prod_name
   , sum(q1.unit_cost)
   , sum(q2.unit_cost)
   , sum(q3.unit_cost)
from sh.products p
   , ( select prod_id, unit_cost from sh.costs where time_id between to_date('01/01/2000','mm/dd/yyyy') and to_date('03/31/2000')) q1
   , ( select prod_id, unit_cost from sh.costs where time_id between to_date('04/01/2000','mm/dd/yyyy') and to_date('06/30/2000')) q2
   , ( select prod_id, unit_cost from sh.costs where time_id between to_date('07/01/2000','mm/dd/yyyy') and to_date('09/30/2000')) q3
where q1.prod_id = p.prod_id
   and q2.prod_id = p.prod_id
   and q3.prod_id = p.prod_id
group by p.prod_name
order by p.prod_name
/
