-- ВАРИАНТ 2
-- Всего одна ТУЗ - катим и обновляем, а также подключаемся под ней.
-- есть 1 внешний ТУЗ, который работает с нашей БД
-- СЛОЖНО? ОЧЕНЬ

-- -----------------------------------------------
-- создание (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
CREATE USER test_user_2 WITH PASSWORD 'test_user_2' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE USER test_user_2_1 WITH PASSWORD 'test_user_2_1' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER

CREATE DATABASE test2 OWNER test_user_2;

-- -----------------------------------------------
-- выполнение под пользователем test_user_2
-- -----------------------------------------------
CREATE SCHEMA user_2;
-- это таблицы
CREATE TABLE user_2.t_users (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_2.t_users (user_name) values ('user');

CREATE TABLE user_2.t_users1 (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_2.t_users1 (user_name) values ('user1');
-- это процедура
CREATE OR REPLACE PROCEDURE user_2.add_numbers(
    a INT,
    b INT,
    OUT result INT
) AS $$
BEGIN
    result := a + b;
END;
$$ LANGUAGE plpgsql;

-- это функция
CREATE OR REPLACE FUNCTION user_2.add_numbers1(a INT, b INT)
RETURNS INT
AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;

-- вызов процедуры и функции
DO $$
DECLARE
    res INT;
BEGIN
    CALL user_2.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_2.add_numbers1(10, 20);
END $$;

-- если подключиться под test_user_2_1, то мы ничего не увидим
-- мы должны под test_user_2 выполнить
GRANT USAGE, CREATE ON SCHEMA user_2 TO test_user_2_1;
GRANT SELECT ON user_2.t_users TO test_user_2_1;
GRANT SELECT ON user_2.t_users1 TO test_user_2_1;
GRANT EXECUTE ON PROCEDURE user_2.add_numbers(INT, INT, INT) TO test_user_2_1; --REVOKE EXECUTE ON PROCEDURE user_2.add_numbers(INT, INT, INT) FROM test_user_2_1;
GRANT EXECUTE ON FUNCTION user_2.add_numbers1(INT, INT) TO test_user_2_1; --REVOKE EXECUTE ON FUNCTION user_2.add_numbers1(INT, INT) FROM test_user_2_1;
GRANT SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA user_2 TO test_user_2_1; --это нужно делать ДО 16 PostgreSQL, иначе если у вас есть sequence, то не вставите в такую таблицу пользователем test_user_2_1 

-- -----------------------------------------------
-- мы должны под test_user_2_1 выполнить
-- -----------------------------------------------
select * from user_2.t_users;
select * from user_2.t_users1;
-- вызов процедуры и функции
DO $$
DECLARE
    res INT;
BEGIN
    CALL user_2.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_2.add_numbers1(10, 20);
END $$;

create table user_2.t ();
select * from user_2.t; -- это будет работать только под пользователем test_user_2_1

-- -----------------------------------------------
-- удалить объекты test_user_2
-- -----------------------------------------------
DROP TABLE user_2.t_users1;
DROP TABLE user_2.t_users;
DROP PROCEDURE user_2.add_numbers; -- вот тут уже не прокатывает путаница названий
DROP FUNCTION user_2.add_numbers1;

-- -----------------------------------------------
-- удаление (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
DROP DATABASE test2;
DROP ROLE test_user_2; -- обратите внимание, что пока тут можно написать и ROLE и USER
DROP USER test_user_2_1; -- обратите внимание, что пока тут можно написать и ROLE и USER
