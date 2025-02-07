-- ВАРИАНТ 4
-- Одна ТУЗ владелец (test_user_4) - катим и обновляем, а также подключаемся под ней.
-- есть 2 внешних ТУЗ, которые работают с нашей БД, могут создавать в ней объекты, но мы делаем так, что НА все новые объекты автоматом выдаются права роли
-- СЛОЖНО? ЧУТЬ ПРОЩЕ
-- ЧТО ХОРОШО:
-- 1. мы не морочим голову с раздачей прав на новые объекты в схеме
-- 2. когда такой подход использовать: когда у вас множество новых объектов и потенциально множество разработчиков могут их создавать
-- ЧТО ПЛОХО:
-- 1. если пользователи test_user_4_1/test_user_4_2 создадут объекты в схеме user_4, то другие пользователи их не увидят

-- создание (выполнение под пользователем SUPERUSER)
CREATE USER test_user_4 WITH PASSWORD 'test_user_4' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE ROLE test_user_4_role NOLOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE USER test_user_4_1 WITH PASSWORD 'test_user_4_1' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
CREATE USER test_user_4_2 WITH PASSWORD 'test_user_4_2' LOGIN; -- обратите внимание, что пока тут можно написать и ROLE и USER
GRANT test_user_4_role TO test_user_4 WITH ADMIN option; -- этим мы говорим, что можем передавать роль

CREATE DATABASE test4 OWNER test_user_4;

-- -----------------------------------------------
-- выполнение под пользователем test_user_4
-- -----------------------------------------------
CREATE SCHEMA user_4;
-- мы должны под test_user_4 выполнить
GRANT USAGE, CREATE ON SCHEMA user_4 TO test_user_4_role;

-- это таблицы
CREATE TABLE user_4.t_users (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_4.t_users (user_name) values ('user');

-- Даём права на чтение из ВСЕХ таблиц схемы user_4, которые будут созданы
ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO test_user_4_role; -- ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM test_user_4_role;
-- Даём права на выполнения для ВСЕХ новых функций и процедур, которые будут созданы в схеме
ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 GRANT EXECUTE ON FUNCTIONS TO test_user_4_role; -- ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 REVOKE EXECUTE ON FUNCTIONS FROM test_user_4_role;
-- Даём права на выполнения для ВСЕХ новых последовательностей, которые будут созданы в схеме (нужно только для версий младше PostgreSQL 16)
ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 GRANT SELECT, UPDATE ON SEQUENCES TO test_user_4_role; -- ALTER DEFAULT PRIVILEGES IN SCHEMA user_4 REVOKE SELECT, UPDATE ON SEQUENCES FROM test_user_4_role;

CREATE TABLE user_4.t_users1 (
    id integer GENERATED ALWAYS AS IDENTITY NOT NULL primary key,
    user_name varchar(255) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);
insert into user_4.t_users1 (user_name) values ('user1');
-- это процедура
CREATE OR REPLACE PROCEDURE user_4.add_numbers(
    a INT,
    b INT,
    OUT result INT
) AS $$
BEGIN
    result := a + b;
END;
$$ LANGUAGE plpgsql;

-- это функция
CREATE OR REPLACE FUNCTION user_4.add_numbers1(a INT, b INT)
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
    CALL user_4.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_4.add_numbers1(10, 20);
END $$;

-- выдадим права на роли (и это всё!!!)
GRANT test_user_4_role TO test_user_4_1 WITH ADMIN option;
GRANT test_user_4_role TO test_user_4_2 WITH ADMIN option;

-- -----------------------------------------------
-- мы должны под test_user_4_1 выполнить и под test_user_4_2
-- -----------------------------------------------
select * from user_4.t_users; -- вот этот запрос завершится ошибкой, потому что мы создали таблицу ДО ALTER DEFAULT PRIVILEGES, надо явно выдать права
-- запустить от test_user_4 GRANT SELECT ON user_4.t_users TO test_user_4_role;
-- после чего запрос select * from user_4.t_users; от пользователя test_user_4_1 будет работать
select * from user_4.t_users1;
-- вызов процедуры и функции
DO $$
DECLARE
    res INT;
BEGIN
    CALL user_4.add_numbers(10, 20, res);
    RAISE NOTICE 'Result add_numbers is %', res;
	RAISE NOTICE 'Result add_numbers1 is %', user_4.add_numbers1(10, 20);
END $$;

create table user_4.t ();
select * from user_4.t; -- это будет работать только под пользователем test_user_4_1

-- -----------------------------------------------
-- удалить объекты test_user_4
-- -----------------------------------------------
DROP TABLE user_4.t_users1;
DROP TABLE user_4.t_users;
DROP PROCEDURE user_4.add_numbers; -- вот тут уже не прокатывает путаница названий
DROP FUNCTION user_4.add_numbers1;

-- -----------------------------------------------
-- удаление (выполнение под пользователем SUPERUSER)
-- -----------------------------------------------
DROP DATABASE test4;
DROP ROLE test_user_4_role; -- обратите внимание, что пока тут можно написать и ROLE и USER
DROP ROLE test_user_4; -- обратите внимание, что пока тут можно написать и ROLE и USER
DROP USER test_user_4_1; -- обратите внимание, что пока тут можно написать и ROLE и USER
DROP USER test_user_4_2; -- обратите внимание, что пока тут можно написать и ROLE и USER
