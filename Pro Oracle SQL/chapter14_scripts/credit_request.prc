create or replace procedure credit_request(p_customer_id    IN NUMBER,
                                           p_amount         IN NUMBER)
                                           
 IS

v_authorization	NUMBER;
 
BEGIN 

  v_authorization := round(dbms_random.value(p_customer_id, p_amount), 0);

--  begin dbms_lock.sleep(60); end;

begin dbms_output.put_line('Customer ID = ' || p_customer_id);
end;

begin dbms_output.put_line('Amount = ' || p_amount);
end;

begin dbms_output.put_line('Authorization = ' || v_authorization);
end;

END credit_request;
/

grant execute on credit_request to oe ;
