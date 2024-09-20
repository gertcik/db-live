@ECHO Install app
docker-compose -f docker-pg.yml down
docker-compose -f docker-pg.yml up -d
pause
