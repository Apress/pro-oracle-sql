/* Listing 3-16 */

alter table hr.employees modify (email null) ;

set autotrace traceonly explain

select email from hr.employees ;

set autotrace off

alter table hr.employees modify (email not null) ;

set autotrace traceonly explain

select email from hr.employees ;

