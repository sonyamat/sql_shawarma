-- (1) Создали view, в котором выписаны все заказы без учета скидки, в которых цены блюд актуальны на сегодняшний день
create or replace view dish_price_view as
select distinct order_id,
string_agg(dish_name, ', ') over(partition by order_id) as "Total",
sum(dish_price) over(partition by order_id) as "SUM"
from shawarma.dish
join shawarma.dish_x_order using(dish_entry_id)
where valid_to_dttm = '9999-12-31 23:59:59.000'
order by "SUM" desc;

--Посмотрели, что сделали
select * from dish_price_view;



-- (2) Создали view, в котором отсортировали стоимости заказов по убыванию и вывели работников, которые эти заказы делали
create or replace view the_best_employee as
select order_id, employee_name, "SUM" - discount_amount as discount
from (
select distinct order_id, employee_name, discount_amount,
string_agg(dish_name, ', ') over(partition by order_id) as "Total",
sum(dish_price) over(partition by order_id) as "SUM"
from shawarma.employee
join shawarma.order using(employee_id)
join shawarma.dish_x_order using (order_id)
join shawarma.dish using (dish_entry_id)
order by "SUM" desc) as payment_nodiscount;

--Посмотрели, что получилось
select * from the_best_employee;



-- (3) Создали view, в котором написаны адреса кафе и стоимости заказов с учетом скидки, их содержание и всё это отсортировали по убыванию.
create or replace view the_best_cafe as 
select distinct cafe_address, "Total", "SUM" - discount_amount as discount
from(select distinct cafe_id, cafe_address, discount_amount, dish_price,
string_agg(dish_name, ', ') over(partition by order_id) as "Total",
sum(dish_price) over(partition by order_id) as "SUM"
from shawarma.cafe
join shawarma.employee e using(cafe_id)
join shawarma.order using(employee_id)
join shawarma.dish_x_order using(order_id)
join shawarma.dish using (dish_entry_id)
order by "SUM" desc) as payment_nodiscount
order by discount desc;

--Вновь посмотрели, что получилось
select * from the_best_cafe;
