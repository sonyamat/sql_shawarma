set search_path = shawarma, public;

-- create table dish
DROP TABLE IF EXISTS shawarma.dish CASCADE;
CREATE TABLE shawarma.dish
(
    dish_id         INT,
    dish_name       VARCHAR(100) NOT NULL,
    dish_price      NUMERIC,
    valid_from_dttm TIMESTAMP    NOT NULL,
    valid_to_dttm   TIMESTAMP    NOT NULL,
    CONSTRAINT dish_primary_key PRIMARY KEY (dish_id, valid_from_dttm),
    CONSTRAINT dish_price CHECK (dish.dish_price > 0 IS NOT NULL)
);

insert into shawarma.dish(dish_id, dish_name, dish_price, valid_from_dttm, valid_to_dttm)
values (10000001, 'Сырная шаверма', 500, '2016-06-08 00:00:00', '2018-06-08 23:59:59'),
       (10000002, 'Шаверма барбекю', 350, '2016-11-08 00:00:00', '9999-12-31 23:59:59'),
       (10000003, 'Шаверма классическая', 300, '2015-11-08 00:00:00', '9999-12-31 23:59:59'),
       (10000004, 'Шаверма с кониной', 900, '2014-11-18 00:00:00', '2018-11-08 23:59:59'),
       (10000005, 'Картофель-фри', 90, '2010-01-01 00:00:00', '2023-04-08 23:59:59'),
       (10000006, 'Шаверма с рыбой фугу', 1000, '2018-11-18 00:00:00', '9999-12-31 23:59:59'),
       (10000001, 'Сырная шаверма', 600, '2018-06-08 23:59:59', '2022-06-08 23:59:59'),
       (10000001, 'Сырная шаверма', 700, '2022-06-08 23:59:59', '9999-12-31 23:59:59'),
       (10000004, 'Шаверма с кониной', 20000, '2018-11-08 00:00:00', '9999-12-31 23:59:59'),
       (10000005, 'Картофель-фри', 10, '2023-04-08 00:00:00', '9999-12-31 23:59:59');

--Первый триггер будет для версионной таблицы dish. При добавлении нового кортежа возможны два случая: либо добавляем новое блюдо 
--либо меняем цену уже существующего. Этот триггер во втором случае будет автоматически менять дату конца прошлой цены на дату начала новой 


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
--После такой вставки кортеж 10 000 001 Сырная шаверма 700 2022-06-08 9999-12-31 превратится в
--10 000 001 Сырная шаверма 700 2022-06-08 2023-06-08
--то есть дата конца старой цены станет датой начала новой автоматически, очень удобно!

--еще пример
insert into shawarma.dish(dish_id, dish_name, dish_price, valid_from_dttm, valid_to_dttm)
values (10000006, 'Шаверма с рыбой фугу', 1000, '2023-07-07 00:00:00', '9999-12-31 23:59:59');
  
select * from dish;


--Второй триггер будет для таблицы Сотрудник. Если ему меняют должность, его зарплата будет 
--автоматически меняться в соответствии с ней.

-- create table employee
DROP TABLE IF EXISTS shawarma.employee CASCADE;
CREATE TABLE shawarma.employee
(
    employee_id           INT,
    cafe_id               INT          NOT NULL,
    employee_name         VARCHAR(100) NOT NULL,
    employee_phone_number VARCHAR(16),
    employee_position     VARCHAR(100),
    salary                NUMERIC,
    CONSTRAINT employee_id PRIMARY KEY (employee_id),
    CONSTRAINT employee_cafe_id FOREIGN KEY (cafe_id) REFERENCES shawarma.cafe (cafe_id),
    CONSTRAINT employee_phone_number CHECK (regexp_match(employee_phone_number,
                                                         '^(8|\+7)\s[0-9]{3}\s[0-9]{3}-[0-9]{2}-[0-9]{2}$') IS NOT NULL),
    CONSTRAINT employee_position CHECK (regexp_match(employee_position,
                                                     '^(Линейный повар|Повар заготовщик|Су-шеф|Шеф|Бренд-шеф|Шеф-кондитер|Официант|Уборщик|Кассир)$') IS NOT NULL),
    CONSTRAINT salary CHECK (salary > 0 IS NOT NULL)
);

insert into shawarma.employee(employee_id, cafe_id, employee_name, employee_phone_number, employee_position, salary)
values (1001, 1, 'Том Круз', '+7 904 170-21-20', 'Кассир', 20000.00),
       (1002, 1, 'Дженнифер Коннелли', '+7 904 987-11-82', 'Линейный повар', 53500.00),
       (1003, 1, 'Эдвард Нортон', '+7 898 316-51-08', 'Повар заготовщик', 42800.00),
       (1004, 2, 'Джон Траволта', '+7 956 123-45-67', 'Официант', 50000.00),
       (1005, 2, 'Ума Турман', '+7 957 321-54-76', 'Шеф-кондитер', 100000.00),
       (1006, 2, 'Сергей Бурунов', '8 904 525-45-23', 'Уборщик', 10000.00),
       (1007, 3, 'Алла Пугачева', '+7 942 242-21-42', 'Кассир', 20000.00),
       (1008, 3, 'Борис Джонсон', '+7 942 214-56-86', 'Уборщик', 10000.00),
       (1009, 3, 'Леонардо Ди Каприо', '8 924 124-12-52', 'Официант', 50000.00),
       (1010, 4, 'Илон Маск', '+7 321 424-32-53', 'Кассир', 20000.00),
       (1011, 4, 'Стив Джобс', '8 904 123-21-32', 'Бренд-шеф', 150000.00),
       (1012, 4, 'Дженнифер Лопес', '+7 412 424-42-65', 'Уборщик', 10000.00),
       (1013, 5, 'Александр Халяпов', '8 909 312-32-53', 'Шеф', 9999999.99),
       (1014, 5, 'Александр Пушкин', '8 903 123-53-32', 'Су-шеф', 200000.00),
       (1015, 5, 'Ананух Гелишвили', '+7 100 100-01-11', 'Официант', 50000.00);

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

--Примеры исполнения: изначально Александр шеф повар с зарплатой 99999.99. 
--После смен должности его зарплата заменится на 20000, 10000 и 200000.
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
