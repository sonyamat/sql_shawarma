create schema for_views; --создадим схему

set search_path = for_views, public; --облегчим себе жизнь



--(1) View, в котором замаскировали номер телефона каждого сотрудника
create or replace view masked_employee_phone_view as
select employee_name,
	case
		when employee_phone_number like '+7%' then concat('+7 XXX XXX-XX-', substring(employee_phone_number, 15))
		else concat('+7 XXX XXX-XX-', substring(employee_phone_number, 14))
	end as masked_phone_number
from shawarma.employee;

--Посмотрим, что всё хорошо
select * from masked_employee_phone_view;



--(2) Хотим посмотреть заказы, без лишней информации
create or replace view shawarma_order_view as 
select payment_amount, payment_type, discount_amount
from shawarma.order;

select * from shawarma_order_view;



--(3) Посмотрим список кафе, но замаскируем номера и еще хотим не отображать лишнюю информацию про id кафе
create or replace view cafe_masked_phone as
select cafe_address, 
		concat('+7 XXX XXX-XX-', substring(cafe_phone_number, 15))
from shawarma.cafe;

select * from cafe_masked_phone;


--(4) Посмотрим на список блюд, цены которых актуальны с заданного периода
select * from shawarma.dish;

create or replace view valid_dish as
select dish_name, dish_price
from shawarma.dish 
where valid_from_dttm > '2012-01-01 00:00:01';

select * from valid_dish;
