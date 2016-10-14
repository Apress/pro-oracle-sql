/* Listing 6-1 */

explain plan for
select e.last_name || ', ' || e.first_name as full_name,
e.phone_number, e.email, e.department_id,
d.department_name, c.country_name, l.city, l.state_province,
r.region_name
from hr.employees e, hr.departments d, hr.countries c,
hr.locations l, hr.regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id;

select * from table(dbms_xplan.display);

set autotrace traceonly explain

select e.last_name || ', ' || e.first_name as full_name,
e.phone_number, e.email, e.department_id,
d.department_name, c.country_name, l.city, l.state_province,
r.region_name
from hr.employees e, hr.departments d, hr.countries c,
hr.locations l, hr.regions r
where e.department_id = d.department_id
and d.location_id = l.location_id
and l.country_id = c.country_id
and c.region_id = r.region_id;

