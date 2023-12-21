-- 1: select employees with big salaries
select employee_name, employee_position
from shawarma.employee
where salary > 100000;

-- 2: select names and phone numbers for cashiers working in 1st cafe
select employee_name, employee_phone_number
from shawarma.employee
where cafe_id = 1
  and employee_position = 'Кассир';

-- 3: insert new employee
insert into shawarma.employee(employee_id, cafe_id, employee_name, employee_phone_number, employee_position, salary)
values (1016, 5, 'Натали Портман', '+7 994 231-22-29', 'Уборщик', 120000.00);

-- 4: all janitors get promoted
update shawarma.employee
set employee_position = 'Кассир'
where employee_position = 'Уборщик';

-- 5: cafe 4 is closed and everyone is fired
delete
from shawarma.employee
where cafe_id = 4;

-- 6: select deliveries received in 2017-2022
select delivery_dttm, cafe_id
from shawarma.delivery
where delivery_dttm > '2017-01-01 00:00:00.000000'
  and delivery_dttm < '2022-01-01 00:00:00.000000';

-- 7: insert new delivery with unknown dttm
insert into shawarma.delivery (delivery_id, cafe_id)
values (10008, 1);

-- 8: delete deliveries with unknown dttm
delete
from shawarma.delivery
where delivery_dttm IS NULL;
