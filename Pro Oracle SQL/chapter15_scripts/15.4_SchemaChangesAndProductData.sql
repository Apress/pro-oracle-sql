--- Schema Changes and New Product Data 

alter table product_information add supplier_product_id varchar2(15);

update product_information
   set supplier_product_id = round(dbms_random.value(100000, 80984),0) ;

commit ;

create sequence product_id start with 3525 ;
create table product_id_effectivity (
       product_id            number,
       new_product_id        number,
       supplier_product_id   varchar(15),
       effective_date        date) ;

insert into product_id_effectivity
(select product_id, 
        product_id.nextval, 
        round(dbms_random.value(100000, 80984),0)||'-'||substr(product_name, instr(product_name,'/',-1,1)+1), '10-oct-10'
   from product_information, dual  where supplier_id = 103089
    and product_name like '%/%') ;select * from product_id_effectivity ;

commit ; 

insert into product_information (
       product_id, 
       product_name, 
       product_description,
       category_id,
       weight_class,
       supplier_id,
       product_status,
       list_price,
       min_price,
       catalog_url,
       supplier_product_id)(select e.new_product_id, 
        p.product_name,
        p.product_description,
        p.category_id,
        p.weight_class,
        p.supplier_id,       'planned', 
        p.list_price, 
        p.min_price, 
        p.catalog_url,
        e.supplier_product_id
   from product_information p, product_id_effectivity e
  where p.product_id = e.product_id    and p.supplier_id = 103089) ; 

select product_id,
       product_name,
       product_status,
       supplier_product_id
  from product_information where supplier_id = 103089
 order by product_id ;

commit ;