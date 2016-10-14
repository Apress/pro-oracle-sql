--- Incorporating ILO into a Procedure
create or replace procedure credit_request(p_customer_id        IN  NUMBER,
                                           p_amount             IN  NUMBER,                                           p_authorization      OUT NUMBER,
                                           p_status_code        OUT NUMBER,
                                           p_status_message     OUT VARCHAR2)IS
/******************************************************************************
  status_code values    status_code status_message
    =========== ===========================================================              0 Success
         -20105 Customer ID must have a non-null value.
         -20110 Requested amount must have a non-null value.
         -20500 Credit Request Declined.******************************************************************************/
  v_authorization NUMBER;
BEGIN ilo_task.begin_task('New Order', 'Credit Request');
SAVEPOINT RequestCredit;

IF ( (p_customer_id) IS NULL ) THEN 
   RAISE_APPLICATION_ERROR(-20105, 'Customer ID must have a non-null value.', TRUE);END IF;
IF ( (p_amount) IS NULL ) THEN
   RAISE_APPLICATION_ERROR(-20110, 'Requested amount must have a non-null value.', TRUE);END IF; 

v_authorization := round(dbms_random.value(p_customer_id, p_amount), 0);

IF ( v_authorization between 324 and 342 ) THEN 
   RAISE_APPLICATION_ERROR(-20500, 'Credit Request Declined.', TRUE);END IF;

p_authorization:= v_authorization; 
p_status_code:= 0; 
p_status_message:= NULL;

ilo_task.end_task;

EXCEPTION
  WHEN OTHERS THEN    p_status_code:= SQLCODE; 
    p_status_message:= SQLERRM;

    BEGIN
      ROLLBACK TO SAVEPOINT RequestCredit;    EXCEPTION WHEN OTHERS THEN NULL;
    END;

ilo_task.end_task(error_num => p_status_code);

END credit_request; 
/