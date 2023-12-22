--Первый триггер будет для версионной таблицы dish. При добавлении нового кортежа возможны два случая: 
--либо добавляем новое блюдо либо меняем цену уже существующего. 
--Этот триггер во втором случае будет автоматически менять дату конца прошлой цены на дату начала новой 


CREATE OR REPLACE FUNCTION trigger_add_dish()
    RETURNS TRIGGER
    AS
$$
    BEGIN
        IF NEW.valid_to_dttm = '9999-12-31 23:59:59' then --если такой продукт уже есть, то есть меняем его цену
            IF (SELECT count(*) FROM shawarma.dish
            WHERE dish_id = NEW.dish_id) > 0 then 
                UPDATE shawarma.dish 
                SET valid_to_dttm = NEW.valid_from_dttm              
                WHERE dish_id = NEW.dish_id and valid_to_dttm = '9999-12-31 23:59:59'; --нужна именно самая последняя версия старой цены
            END IF;
        END IF;
        RETURN NEW;
    END
$$  LANGUAGE plpgsql;

CREATE or replace TRIGGER trigger_dish_update
   BEFORE INSERT --чтобы не применялась также к новому кортежу 
   ON shawarma.dish
   FOR EACH ROW
   EXECUTE PROCEDURE trigger_add_dish();

--пример работы: 
--допустим, уже есть запись о сырной шаурме: с 2016 по 2018 год она стоила 500 рублей
--с 2018 по 2020 - 600 рублей
--c 2022 по настоящий момент она стоит 700 рублей
--время поднять цену! 
insert into shawarma.dish(dish_id, dish_name, dish_price, valid_from_dttm, valid_to_dttm)
values (10000001, 'Сырная шаверма', 800, '2023-06-08 00:00:00', '9999-12-31 23:59:59');
--После такой вставки кортеж (10 000 001, 'Сырная шаверма', 700, '2022-06-08 9999-12-31') превратится в
--(10 000 001, 'Сырная шаверма', 700, '2022-06-08 2023-06-08')
--то есть дата конца старой цены станет датой начала новой автоматически, очень удобно!

--еще пример
insert into shawarma.dish(dish_id, dish_name, dish_price, valid_from_dttm, valid_to_dttm)
values (10000006, 'Шаверма с рыбой фугу', 1000, '2023-07-07 00:00:00', '9999-12-31 23:59:59');
  
select * from dish;

--Второй триггер будет для таблицы Сотрудник. Если ему меняют должность, его зарплата будет 
--автоматически меняться в соответствии с ней.

select * from employee e;

CREATE OR REPLACE FUNCTION trigger_change_position()
    RETURNS TRIGGER
    AS
$$
	DECLARE new_salary numeric := 1;
    BEGIN
	    case
	    when NEW.employee_position = 'Кассир' then new_salary := 20000.00;
	   	when NEW.employee_position = 'Уборщик' then new_salary := 10000.00;
	    when NEW.employee_position = 'Официант' then new_salary := 50000.00;
	    when NEW.employee_position = 'Шеф-кондитер' then new_salary := 100000.00;
	    when NEW.employee_position = 'Бренд-шеф' then new_salary := 150000.00;
	   	when NEW.employee_position = 'Шеф' then new_salary := 9999999.99;
	  	when NEW.employee_position = 'Су-шеф' then new_salary := 200000.00;
	 	when NEW.employee_position = 'Повар заготовщик' then new_salary := 42800.00;
	 	when NEW.employee_position = 'Линейный повар' then new_salary := 53500.00;
	    else RAISE EXCEPTION 'Такой должности еще нет в базе';
	    end case;
        UPDATE shawarma.employee
        SET salary = new_salary         
        WHERE employee_id = NEW.employee_id;
        RETURN NEW;
    END;
$$  LANGUAGE plpgsql;

CREATE or replace TRIGGER trigger_position_update
   AFTER update of employee_position
   ON shawarma.employee
   FOR EACH ROW
   EXECUTE PROCEDURE trigger_change_position();

--Примеры исполнения: изначально Александр шеф повар с зарплатой 999999.99. 
--После смен должности его зарплата заменится на 20000, 10000 и 200000 автоматически
update shawarma.employee
set employee_position = 'Кассир'
where employee_name = 'Александр Халяпов';
update shawarma.employee
set employee_position = 'Уборщик'
where employee_name = 'Александр Халяпов';
update shawarma.employee
set employee_position = 'Су-шеф'
where employee_name = 'Александр Халяпов';

select * from employee e;
