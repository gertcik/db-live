-- полезные скрипт по соединениям в PostgreSQL
-- вдохновялись информацией из
-- https://edu.postgrespro.ru/16/dba1-16/dba1_12_admin_monitoring.html

-- статистика по соединениям (кто съедает больше всех соединений)
select 
	usename,
	application_name,
	datname as db_name,
	state,
	count(1) as num_connections 
from pg_stat_activity 
group by usename,application_name,datname,state
order by 5 desc

-- все соединяния, включая последние запросы
select 
	usename,
	datname as db_name,
	state,
	query
from pg_stat_activity 

-- оценка процента использованных сервером соединений
-- если connections_utilization_pctg > 85
-- то что-то не так и надо думать о новом сервере или расширении ресурса существующего
select 
	A.total_connections, 
	A.non_idle_connections, 
	B.max_connections,
	round((100 * A.total_connections::numeric / B.max_connections::numeric), 2) connections_utilization_pctg
from
	(select count(1) as total_connections, sum(case when state!='idle' then 1 else 0 end) as non_idle_connections from pg_stat_activity) A,
	(select setting as max_connections from pg_settings where name='max_connections') B;