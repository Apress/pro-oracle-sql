select last_name from hr.employees
where department_id in (select department_id from hr.departments where department_name like 'I%')
/
select last_name from hr.employees emp
where exists (select null from hr.departments dept where emp.department_id = dept.department_id and department_name like 'I%')
/
