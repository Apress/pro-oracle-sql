/* Listing 2-5 */


set autotrace on

SELECT e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id AND e1.salary > v.avg_salary;

SELECT /*+ MERGE(v) */ e1.last_name, e1.salary, v.avg_salary
FROM hr.employees e1,
(SELECT department_id, avg(salary) avg_salary
FROM hr.employees e2
GROUP BY department_id) v
WHERE e1.department_id = v.department_id AND e1.salary > v.avg_salary;

