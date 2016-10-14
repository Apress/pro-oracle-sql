CREATE OR REPLACE FUNCTION Get_ListPrice(p_product_id IN product_information.product_id%TYPE) 
   RETURN NUMBER

 IS

  v_list_price NUMBER;

BEGIN 

  IF ( (p_product_id) IS NULL ) THEN
    RETURN NULL;
  END IF;

  SELECT
    list_price
  INTO v_list_price
  FROM (SELECT list_price
          from product_information
         where product_id = p_product_id);

  RETURN v_list_price;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

END Get_ListPrice;
/
