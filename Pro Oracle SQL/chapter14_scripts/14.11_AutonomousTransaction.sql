create table order_log  (    customer_id        number not null,
    order_id           number not null,
    order_date         number not null,
    order_outcome      varchar2(10)   constraint order_log_pk primary key (customer_id, order_id, order_date)
 );

create or replace procedure record_new_order (p_customer_id IN NUMBER,
                                              p_order_id    IN NUMBER)  as
 pragma autonomous_transaction;
 begin   insert into order_log
    (customer_id, order_id, order_date)   values 
    (p_customer_id, p_order_id, sysdate);

 commit;
 end;
/