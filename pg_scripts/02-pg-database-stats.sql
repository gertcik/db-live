-- размер всех БД в байтах
select now(), datname, pg_database_size(datname) from pg_catalog.pg_database order by pg_database_size(datname) DESC

-- размер всех БД отформатированный (в килобайты, мегабайти и т.п.)
select now(), datname, pg_size_pretty(pg_database_size(datname)) from pg_catalog.pg_database order by pg_database_size(datname) DESC