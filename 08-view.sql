-- (1) Создали view, в котором выписаны все заказы, в которых цена блюда актуальна на сегодняшний день
create or replace view dish_price_view as
select dish_entry_id, dish_name, dish_price, order_id
from dish
join dish_x_order using(dish_entry_id)
where valid_to_dttm = '9999-12-31 23:59:59.000'

--Посмотрели, что мы создали
select * from dish_price_view;

--Теперь отсортируем заказы по убыванию их стоимости
select sum(dish_price), order_id, string_agg(dish_name, ', ')  "Order list"
from dish_price_view
group by order_id
order by sum(dish_price) desc;



-- (2) Создали view, в котором собрали работников заведений и то, какие они заказы делали в заданный период
create or replace view the_best_employee1 as
select employee_id, employee_name, order_id, payment_amount
from employee
join shawarma.order using(employee_id)
where order_dttm between '2001-01-01 00:00:00' and '2015-01-01 00:00:00';

--Посмотрели, что получилось
select * from the_best_employee1;

--Теперь отсортируем и выведем работников по прибыли, которую они принесли заведению, лучшему -- премия
select employee_name, sum(payment_amount)
from the_best_employee1
group by employee_name
order by sum(payment_amount) desc; 



-- (3) Создали view, в котором написаны адреса кафе и стоимости заказов, сделанных в них
create or replace view the_best_cafe as 
select cafe_address, payment_amount
from cafe
join employee e using(cafe_id)
join shawarma.order using(employee_id);

--Вновь посмотрели, что получилось
select * from the_best_cafe;

--Отсортируем кафе от самого прибыльного до самого НЕприбыльного
select cafe_address, sum(payment_amount)
from the_best_cafe
group by cafe_address
order by sum(payment_amount) desc; 
