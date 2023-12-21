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
