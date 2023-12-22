-- calculate average salary for each employee position
select employee_position, avg(salary)
from shawarma.employee
group by employee_position;

-- calculate count of the orders with discount for each payment_type
select payment_type, count(discount_amount)
from (
    select payment_type, discount_amount
    from shawarma.order
    where discount_amount > 0) as notzero_discount
group by payment_type;

-- print all cheese deliveries sorted by time
select product_name, delivery_dttm, quantity
from (
    select product_name, delivery_id, quantity
    from shawarma.product
    join shawarma.product_x_delivery
    on product.product_id = product_x_delivery.product_id) as product_delivery
join shawarma.delivery on product_delivery.delivery_id = delivery.delivery_id
where product_name = 'Сыр'
order by delivery_dttm;

-- print dish prices for each dish sorted by time
select dish_name, valid_from_dttm, valid_to_dttm, dish_price,
rank() over (partition by dish_name order by valid_from_dttm desc)
from shawarma.dish;

-- calculate the revenue for each cafe, taking into account discounts
select cafe_address, sum(revenue)
from (
    select cafe_id, (order_sum - discount_amount) as revenue from (
        select o.order_id, employee_id, sum(dish_price) as order_sum, discount_amount from (
            select order_id, dish_price from shawarma.dish
            join shawarma.dish_x_order on dish.dish_entry_id = dish_x_order.dish_entry_id) as od_dish
        join shawarma.order as o on o.order_id = od_dish.order_id
        group by o.order_id) as order_dish
    join shawarma.employee on employee.employee_id = order_dish.employee_id) as employee_dish
join shawarma.cafe on cafe.cafe_id = employee_dish.cafe_id
group by cafe_address;

-- print all cafe deliveries sorted by time
select cafe_address, product_name, delivery_dttm, quantity,
dense_rank() over (partition by cafe_address order by delivery_dttm)
from (
    select product_name, cafe_id, delivery_dttm, quantity
    from (
        select product_name, delivery_id, quantity
        from shawarma.product
        join shawarma.product_x_delivery on product.product_id = product_x_delivery.product_id) as product_delivery
    join shawarma.delivery on product_delivery.delivery_id = delivery.delivery_id) as pd_delivery
join shawarma.cafe on pd_delivery.cafe_id = cafe.cafe_id;

-- print all products that were used for each cafe
select distinct cafe_address, product_name,
count(product_name) over (partition by cafe_address, product_name)
from (
    select cafe_id, product_name from (
        select o.order_id, employee_id, product_name from (
            select product_name, order_id from (
                select product_name, dish.dish_entry_id from (
                    select product_name, dish_entry_id from shawarma.product
                    join shawarma.product_x_dish on product.product_id = product_x_dish.product_id) as pd_product
                join shawarma.dish on pd_product.dish_entry_id = dish.dish_entry_id) as product_dish
            join shawarma.dish_x_order on product_dish.dish_entry_id = dish_x_order.dish_entry_id) as od_dish
        join shawarma.order as o on o.order_id = od_dish.order_id) as order_dish
    join shawarma.employee on employee.employee_id = order_dish.employee_id) as employee_dish
join shawarma.cafe on cafe.cafe_id = employee_dish.cafe_id;
