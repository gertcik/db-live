# Как развернуть PostgreSQL в контейнере на собственном компьютере:

## 1. Что такое контейнер? Какую проблему решает? Как работает?

Как устанавливалось ПО до появления Docker? - на локальный компьютере
Как запустить несколько экземпляров разных серверов БД на одном компьютере - сложно и требует настройки

### Архитектура Docker

<p>
  <img src="images/docker.jpg" style="width: 680px" />
</p>

3 ключевых компонента в архитектуре Docker: 

- Docker client 
    
    docker client обращается с Docker daemon. 

- Docker host 

    Docker daemon слушает запросы для Docker API и управляет объектами докер - images, containers, networks, and volumes. 

- Docker registry 

    Docker registry сохраняет Docker images. Docker Hub это публичный репозиторий докер. 

Подробнее тут:
https://github.com/ByteByteGoHq/system-design-101?tab=readme-ov-file#how-does-docker-work

## 2. Говорим как провести настройку Docker на Windows

Ставим Docker Desktop Windows + WSL2 по инструкции:
https://docs.docker.com/desktop/

Запускаем UI.

На linux процесс похожий, но нет UI.

## 3. Как запустить PostgreSQL standalone (без docker-compose)

```
docker run --name postgres-test -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=postgres -d postgres:16.1
```
Такая команда создаст экземпляр PostgreSQL в контейнере.

Но есть проблемы - не понятно куда сохраняются данные.

Как это решать?

Явно прописать каталог БД

## 4. Зачем нужен docker-compose, какую проблему он решает?

Если вам нужно запустить несколько контейнеров и прописать конфигурации, то это всё можно оформить в одном файле пример [docker-pg.yml](docker-pg.yml)

```
# остановить docker-compose
docker-compose -f docker-pg.yml down

# запустить docker-compose
docker-compose -f docker-pg.yml up -d
```


## 5. Особенности конфигурирования в Docker

- где хранить БД (как это настроить)
- как накатывать первичные скрипты
- как настроить health-check

## 6. Как быстро развернуть PostgreSQL и pgAdmin4 (без установки чего-либо кроме Docker на комп)

Берём docker image PostgreSQL отсюда
https://hub.docker.com/_/postgres

## 7. Ссылка на репозиторий с примерами
1. Сделать репозиторий
2. Создать readme.md
3. Создать docker-compose

## 8. Прочее

```
# список процессов docker
docker ps

# статистика запущенных контейнеров cpu/ram и т.п.
docker stats
```

Если возникают проблемы с Docker на windows, он не стартует.
Видим вот такую диагностик, то можно попробовать удалить всё и создать заново
running engine: waiting for the VM setup to be ready: starting WSL engine: bootstrapping in the main distro: starting wsl-bootstrap: context canceled
```
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data
```
