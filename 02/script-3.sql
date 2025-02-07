-- ВАРИАНТ 3
-- Всего одна ТУЗ - катим и обновляем, а также подключаемся под ней.
-- есть 2 внешних ТУЗ, которые работают с нашей БД, могут создавать в ней объекты
-- СЛОЖНО? ЧУТЬ ПРОЩЕ
-- ЧТО ХОРОШО:
-- 1. Мы выдаём роли права сразу на все объекты схемы (это не всегда может быть приемлемо)
-- 2. Выдача прав у нас простая

-- -----------------------------------------------
-- создание (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
CREATE USER test_user_3 WITH PASSWORD 'test_user_3' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE ROLE test_user_3_role NOLOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE USER test_user_3_1 WITH PASSWORD 'test_user_3_1' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE USER test_user_3_2 WITH PASSWORD 'test_user_3_2' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
GRANT test_user_3_role TO test_user_3 WITH ADMIN option; -- этим мы говорим, что можем передавать роль

CREATE DATABASE test3 OWNER test_user_3;

-- -----------------------------------------------
-- выполнение под пользователем test_user_1
-- -----------------------------------------------
CREATE SCHEMA user_3;
-- это таблицы
CREATE TABLE user_3.t_users (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_3.t_users (user_name) values ('user');

CREATE TABLE user_3.t_users1 (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_3.t_users1 (user_name) values ('user1');
-- это процедура
CREATE OR REPLACE PROCEDURE user_3.add_numbers(
    a INT,
    b INT,
    OUT result INT
) AS $$
BEGIN
    result := a + b;
END;
$$ LANGUAGE plpgsql;

-- это функция
CREATE OR REPLACE FUNCTION user_3.add_numbers1(a INT, b INT)
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
    CALL user_3.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_3.add_numbers1(10, 20);
END $$;

-- -----------------------------------------------
-- если подключиться под test_user_3_1, то мы ничего не увидим
-- -----------------------------------------------
-- мы должны под test_user_3 выполнить
GRANT USAGE, CREATE ON SCHEMA user_3 TO test_user_3_role;

-- выдадим права массово на все таблицы схемы
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA user_3 TO test_user_3_role; --REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA user_3 FROM test_user_3_role;
-- выдадим права массово на все процедуры и функции схемы
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA user_3 TO test_user_3_role; --REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA user_3 FROM test_user_3_role;
GRANT SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA user_3 TO test_user_3_1; --это нужно делать ДО 16 PostgreSQL, иначе если у вас есть sequence, то не вставите в такую таблицу пользователем test_user_2_1 

GRANT test_user_3_role TO test_user_3_1 WITH ADMIN option;
GRANT test_user_3_role TO test_user_3_2 WITH ADMIN option;

-- -----------------------------------------------
-- мы должны под test_user_3_1 выполнить и под test_user_3_2
-- -----------------------------------------------
select * from user_3.t_users;
select * from user_3.t_users1;
-- вызов процедуры и функции
DO $$
DECLARE
    res INT;
BEGIN
    CALL user_3.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_3.add_numbers1(10, 20);
END $$;

create table user_3.t ();
select * from user_3.t; -- это будет работать только под пользователем test_user_3_1

-- -----------------------------------------------
-- удалить объекты test_user_3
-- -----------------------------------------------
DROP TABLE user_3.t_users1;
DROP TABLE user_3.t_users;
DROP PROCEDURE user_3.add_numbers; -- вот тут уже не прокатывает путаница названий
DROP FUNCTION user_3.add_numbers1;

-- -----------------------------------------------
-- удаление (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
DROP DATABASE test3;
DROP ROLE test_user_3; -- обратите внимание, что пока тут можно написать и ROLE и USER
DROP USER test_user_3_1; -- обратите внимание, что пока тут можно написать и ROLE и USER
