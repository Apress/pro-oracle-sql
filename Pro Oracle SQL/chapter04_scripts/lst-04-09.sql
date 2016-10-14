/* Listing 4-9 */


select null from dual
union
select null from dual
;

select null from dual
union all
select null from dual
;

select null from dual
intersect
select null from dual
;

select null from dual
minus
select null from dual
;

select 1 from dual
union
select null from dual
;

select 1 from dual
union all
select null from dual
;

select 1 from dual
intersect
select null from dual
;

select 1 from dual
minus
select null from dual
;
