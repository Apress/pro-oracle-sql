CREATE OR REPLACE FUNCTION Get_OrderTotal(p_order_id IN orders.order_id%TYPE) 
RETURN NUMBER
 IS

  v_order_total NUMBER;

BEGIN 

  IF ( (p_order_id) IS NULL ) THEN
    RETURN NULL;
  END IF;

  SELECT TOTAL
    INTO v_order_total
    FROM (SELECT sum(line_item_total) TOTAL from order_detail_line_items where order_id = p_order_id);

  RETURN v_order_total;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  WHEN OTHERS THEN 
    RAISE;

END Get_OrderTotal;
/
