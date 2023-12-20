-- create schema
DROP SCHEMA IF EXISTS shawarma CASCADE;
CREATE SCHEMA shawarma;

-- create table cafe
DROP TABLE IF EXISTS shawarma.cafe CASCADE;
CREATE TABLE shawarma.cafe
(
    cafe_id           INT,
    cafe_address      TEXT NOT NULL,
    cafe_phone_number VARCHAR(16),
    CONSTRAINT cafe_id PRIMARY KEY (cafe_id),
    CONSTRAINT cafe_phone_number CHECK (regexp_match(cafe_phone_number,
                                                     '^(8|\+7)\s[0-9]{3}\s[0-9]{3}-[0-9]{2}-[0-9]{2}$') IS NOT NULL)
);

-- create table employee
DROP TABLE IF EXISTS shawarma.employee CASCADE;
CREATE TABLE shawarma.employee
(
    employee_id           INT,
    cafe_id               INT          NOT NULL,
    employee_name         VARCHAR(100) NOT NULL,
    employee_phone_number VARCHAR(16),
    employee_position     VARCHAR(10),
    salary                NUMERIC,
    CONSTRAINT employee_id PRIMARY KEY (employee_id),
    CONSTRAINT employee_cafe_id FOREIGN KEY (cafe_id) REFERENCES shawarma.cafe (cafe_id),
    CONSTRAINT employee_phone_number CHECK (regexp_match(employee_phone_number,
                                                         '^(8|\+7)\s[0-9]{3}\s[0-9]{3}-[0-9]{2}-[0-9]{2}$') IS NOT NULL),
    CONSTRAINT employee_position CHECK (regexp_match(employee_position,
                                                     '^(Кассир|Повар|Уборщик)$') IS NOT NULL),
    CONSTRAINT salary CHECK (salary > 0 IS NOT NULL)
);

-- create table product
DROP TABLE IF EXISTS shawarma.product CASCADE;
CREATE TABLE shawarma.product
(
    product_id   INT,
    product_name VARCHAR(100) NOT NULL,
    CONSTRAINT product_id PRIMARY KEY (product_id)
);

-- create table delivery
DROP TABLE IF EXISTS shawarma.delivery CASCADE;
CREATE TABLE shawarma.delivery
(
    delivery_id   INT,
    cafe_id       INT NOT NULL,
    delivery_dttm TIMESTAMP,
    CONSTRAINT delivery_id PRIMARY KEY (delivery_id),
    CONSTRAINT delivery_cafe_id FOREIGN KEY (cafe_id) REFERENCES shawarma.cafe (cafe_id)
);

-- create table product_x_delivery
DROP TABLE IF EXISTS shawarma.product_x_delivery CASCADE;
CREATE TABLE shawarma.product_x_delivery
(
    product_id  INT,
    delivery_id INT,
    CONSTRAINT product_x_delivery_primary_key PRIMARY KEY (product_id, delivery_id),
    CONSTRAINT product_x_delivery_product FOREIGN KEY (product_id) REFERENCES shawarma.product (product_id),
    CONSTRAINT product_x_delivery_delivery FOREIGN KEY (delivery_id) REFERENCES shawarma.delivery (delivery_id)
);

-- create table dish
DROP TABLE IF EXISTS shawarma.dish CASCADE;
CREATE TABLE shawarma.dish
(
    dish_id         INT,
    dish_name       VARCHAR(100) NOT NULL,
    dish_price      NUMERIC,
    valid_from_dttm TIMESTAMP    NOT NULL,
    valid_to_dttm   TIMESTAMP    NOT NULL,
    CONSTRAINT dish_id PRIMARY KEY (dish_id),
    CONSTRAINT dish_price CHECK (dish.dish_price > 0 IS NOT NULL)
);

-- create table product_x_dish
DROP TABLE IF EXISTS shawarma.product_x_dish CASCADE;
CREATE TABLE shawarma.product_x_dish
(
    product_id INT,
    dish_id    INT,
    CONSTRAINT product_x_dish_primary_key PRIMARY KEY (product_id, dish_id),
    CONSTRAINT product_x_dish_product FOREIGN KEY (product_id) REFERENCES shawarma.product (product_id),
    CONSTRAINT product_x_dish_dish FOREIGN KEY (dish_id) REFERENCES shawarma.dish (dish_id)
);


-- create table order
DROP TABLE IF EXISTS shawarma.order CASCADE;
CREATE TABLE shawarma.order
(
    order_id        INT,
    employee_id     INT       NOT NULL,
    order_dttm      TIMESTAMP NOT NULL,
    payment_amount  NUMERIC   NOT NULL,
    payment_type    VARCHAR(10),
    discount_amount NUMERIC,
    CONSTRAINT order_id PRIMARY KEY (order_id),
    CONSTRAINT order_employee_id FOREIGN KEY (employee_id) REFERENCES shawarma.employee (employee_id),
    CONSTRAINT payment_amount CHECK (payment_amount > 0 IS NOT NULL),
    CONSTRAINT payment_type CHECK (regexp_match(payment_type,
                                                '^(cash|bank card)$') IS NOT NULL)
);

-- create table dish_x_order
DROP TABLE IF EXISTS shawarma.dish_x_order CASCADE;
CREATE TABLE shawarma.dish_x_order
(
    dish_id  INT,
    order_id INT,
    CONSTRAINT dish_x_order_primary_key PRIMARY KEY (order_id, dish_id),
    CONSTRAINT dish_x_order_dish FOREIGN KEY (dish_id) REFERENCES shawarma.dish (dish_id),
    CONSTRAINT dish_x_order_order FOREIGN KEY (order_id) REFERENCES shawarma.order (order_id)
);
