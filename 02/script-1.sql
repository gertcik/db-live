-- ВАРИАНТ 1
-- Всего одна ТУЗ - катим и обновляем, а также подключаемся под ней.

-- -----------------------------------------------
-- создание (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
CREATE USER test_user_1 WITH PASSWORD 'test_user_1' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER

CREATE DATABASE test1 OWNER test_user_1;

-- -----------------------------------------------
-- выполнение под пользователем test_user_1
-- -----------------------------------------------
CREATE SCHEMA user_1;
-- это таблицы
CREATE TABLE user_1.t_users (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_1.t_users (user_name) values ('user');

CREATE TABLE user_1.t_users1 (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_1.t_users1 (user_name) values ('user1');
-- это процедура
CREATE OR REPLACE PROCEDURE user_1.add_numbers(
    a INT,
    b INT,
    OUT result INT
) AS $$
BEGIN
    result := a + b;
END;
$$ LANGUAGE plpgsql;

-- это функция
CREATE OR REPLACE FUNCTION user_1.add_numbers1(a INT, b INT)
RETURNS INT
AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------
-- мы должны под test_user_1_1 выполнить
-- -----------------------------------------------
select * from user_1.t_users;
select * from user_1.t_users1;
-- вызов процедуры и функции
DO $$
DECLARE
    res INT;
BEGIN
    CALL user_1.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_1.add_numbers1(10, 20);
END $$;

-- -----------------------------------------------
-- удалить объекты test_user_1
-- -----------------------------------------------
DROP TABLE user_1.t_users1;
DROP TABLE user_1.t_users;
DROP PROCEDURE user_1.add_numbers; -- вот тут уже не прокатывает путаница названий
DROP FUNCTION user_1.add_numbers1;

-- -----------------------------------------------
-- удаление (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
DROP DATABASE test1;
DROP ROLE test_user_1; -- обратите внимание, что пока тут можно написать и ROLE и USER