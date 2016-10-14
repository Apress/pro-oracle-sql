CREATE OR REPLACE FUNCTION Get_OrderItemCount(p_order_id IN orders.order_id%TYPE) 
RETURN NUMBER
 IS

  v_order_item_count NUMBER;

BEGIN 

  IF ( (p_order_id) IS NULL ) THEN
    RETURN NULL;
  END IF;

  SELECT ITEM_COUNT
    INTO v_order_item_count
    FROM (SELECT count(line_item_id) ITEM_COUNT
            from order_detail_line_items
           where order_id = p_order_id);

  RETURN v_order_item_count;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;

  WHEN OTHERS THEN
    RAISE;

END Get_OrderItemCount;
/
