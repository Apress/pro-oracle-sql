/* Listing 2-9 */

set autotrace traceonly explain

SELECT e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id
AND e1.salary > v.avg_salary
AND e1.department_id = 60;

SELECT e1.last_name, e1.salary, v.avg_salary             
FROM hr.employees e1,                                     
(SELECT department_id, avg(salary) avg_salary          
FROM hr.employees e2                                      
WHERE rownum > 1 -- rownum prohibits predicate pushing!
GROUP BY department_id) v                              
WHERE e1.department_id = v.department_id
AND e1.salary > v.avg_salary          
AND e1.department_id = 60;            
