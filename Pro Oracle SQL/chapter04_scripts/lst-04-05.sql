/* Listing 4-5 */


select color from table1
minus
select color from table2;

select distinct color from table1
where not exists (select null from table2 where table2.color = table1.color) ;

select color from table2
minus
select color from table1;

select color from table1
minus
select color from table3;

