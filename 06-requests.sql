-- calculate average salary for each employee position
select employee_position, avg(salary)
from shawarma.employee
group by employee_position;

-- calculate count of the orders with discount for each payment_type
select payment_type, count(*)
from (select payment_type, discount_amount
from shawarma.order
group by payment_type, discount_amount
having discount_amount > 0) as ptype_discount
group by payment_type;

-- print all cheese deliveries sorted by time
select product_name, delivery_dttm
from (select product_name, delivery_id
from shawarma.product
join shawarma.product_x_delivery
on product.product_id = product_x_delivery.product_id) as product_delivery
join shawarma.delivery on product_delivery.delivery_id = delivery.delivery_id
where product_name = 'Сыр'
order by delivery_dttm;

-- print salaries ratings for each employee position
select employee_position, employee_name, salary,
rank() over (partition by employee_position order by salary desc)
from shawarma.employee;

-- calculate the revenue for each cafe, taking into account discounts
select cafe_address, sum(payment_amount - discount_amount) as revenue
from (select cafe_address, employee_id from shawarma.cafe
join shawarma.employee on cafe.cafe_id = employee.cafe_id) as cafe_employee
join shawarma.order on shawarma.order.employee_id = cafe_employee.employee_id
group by cafe_address;
