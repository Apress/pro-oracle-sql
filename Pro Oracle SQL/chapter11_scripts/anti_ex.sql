select /* not in */ department_name 
   from hr.departments
   where department_id not in (select department_id from hr.employees);

select /* not exists */ department_name 
   from hr.departments dept
   where not exists (select null from hr.employees emp 
                    where emp.department_id = dept.department_id);

