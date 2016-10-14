SELECT /* full outer */ d.department_id, e.employee_id
FROM hr.employees e
FULL OUTER JOIN hr.departments d
ON e.department_id = d.department_id
ORDER BY d.department_id;

SELECT /* full outer anti */ /*+ NO_NATIVE_FULL_OUTER_JOIN */
d.department_id, e.employee_id
FROM hr.employees e
FULL OUTER JOIN hr.departments d
ON e.department_id = d.department_id
ORDER BY d.department_id;
