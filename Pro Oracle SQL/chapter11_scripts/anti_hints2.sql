alter session set "_always_anti_join"=hash;
select /* NOT IN NL HINT */ department_name
   from hr.departments dept
   where department_id not in (select /*+ nl_aj */ department_id from hr.employees emp);
alter session set "_always_anti_join"=nested_loops;
select /* NOT IN NL HINT */ department_name
   from hr.departments dept
   where department_id not in (select /*+ nl_aj */ department_id from hr.employees emp);
alter session set "_always_anti_join"=choose;
