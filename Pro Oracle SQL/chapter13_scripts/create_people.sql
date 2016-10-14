create table people 
(person_id number, first_name varchar2(80), last_name varchar2(80),  parent_id number);

create table denormalized_people 
(person_id number, first_name varchar2(80), last_name varchar2(80),  
child1 varchar2(80), 
child2 varchar2(80), 
child3 varchar2(80), 
child4 varchar2(80), 
child5 varchar2(80), 
child6 varchar2(80), 
child7 varchar2(80), 
child8 varchar2(80), 
child9 varchar2(80), 
child10 varchar2(80), 
child11 varchar2(80),
child12 varchar2(80));

create sequence people_seq start with 1000;

create or replace trigger people_autonumber
before insert on people for each row
begin
    if :new.person_id is null then
        select people_seq.nextval into :new.person_id from dual;
    end if;
end;
/

insert into denormalized_people (person_id, first_name, last_name) 
select employee_id, first_name, last_name from hr.employees;

update denormalized_people set child1 = 'Jordan', child2='Jacob', child3='Noah', child4='Lindsey';

