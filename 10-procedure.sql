select * from product;
select * from shawarma.delivery;
select * from shawarma.product_x_delivery;
select * from cafe c;

--Логика работы процедуры: на вход подается айди поставки и кафе, дата. А также массив айди продуктов и массив количеств этих продуктов
--осуществяется вставка в таблицы delivery и delivery_x_product
--Если указано неверное кафе, повторяется айди поставки или среди айди продуктов есть несущствующее - 
--в таблицу ничего не добавляется и выкидывается исключение

CREATE OR REPLACE PROCEDURE insert_delivery(id_of_delivery int,
                                    		id_of_cafe int,
                                    		date_of_delivery TIMESTAMP,
                                    		product_ids int[],
                                    		products_quantities int[])
LANGUAGE plpgsql
AS
$$
	DECLARE partic_product_id int;
	 		counter int := 1;
    begin
        IF (SELECT count(*) FROM shawarma.delivery
                            WHERE delivery_id = id_of_delivery) > 0 THEN
            RAISE EXCEPTION 'Эта поставка уже была';
        END IF;
        IF (SELECT count(*) FROM shawarma.cafe
                            WHERE cafe_id = id_of_cafe) = 0 THEN
            RAISE EXCEPTION 'Такого кафе не существует';
        END IF;
        INSERT INTO shawarma.delivery(delivery_id, cafe_id, delivery_dttm)
        VALUES (id_of_delivery, id_of_cafe, date_of_delivery);
        COMMIT;
        FOREACH partic_product_id IN ARRAY product_ids
        LOOP
	        IF (SELECT count(*) FROM shawarma.product
                            WHERE product_id  = partic_product_id) = 0 then
            ROLLBACK;
            RAISE EXCEPTION 'Введен несуществующий продукт'; 
            EXIT;
        	END IF;
        	INSERT INTO shawarma.product_x_delivery (product_id, delivery_id, quantity)
                VALUES (partic_product_id, id_of_delivery, products_quantities[counter]);
                counter := counter + 1;
        END LOOP;
        COMMIT;
    END;
$$;

--Пример входных данных без ошибок
call insert_delivery(10041, 4, '2017-06-08 15:12:03' , ARRAY [20001, 20002], array [1, 2]); --тут всё корректно вставится
--Примеры с ошибками во входных данных
call insert_delivery(10008, 4, '2017-06-08 15:12:03', ARRAY [20001, 20002], array [1, 2]); --такая поставка уже была
call insert_delivery(10009, 10, '2017-06-08 15:12:03', ARRAY [20001, 20002], array [1, 2]);  --такого кафе не существует
call insert_delivery(10100, 4, '2017-06-08 15:12:03', ARRAY [21, 22], array[1,2]); --ошибка в id продуктов

select * from delivery d;
select * from product_x_delivery pxd;
