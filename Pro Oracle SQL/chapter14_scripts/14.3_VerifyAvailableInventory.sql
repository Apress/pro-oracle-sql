select product_id, quantity_on_hand
  from inventories where product_id in (2255, 2274, 2537)
 order by product_id ;