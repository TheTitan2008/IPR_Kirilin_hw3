## Шаблон для третьего ДЗ по ИПР

Условие дз доступно по [ссылке](https://github.com/Nikfilk2030/missing_semester_hse_cs/blob/main/2026/amcs/year_1/hw_3/README.md)


не мы делааем свой редми

сначала надо собрать докер образ и запустить контейнеры 
docker compose up -d --build
некст можно смотреть как они работают и остнавливать их командами 
docker compose ps
docker compose down

в енв есть два параметра  - порт приложения и текст привествия (он итак хороший текст лучше не менять )

как проверить приложение

посмотерть счетчик -  curl.exe http://localhost:8080/
увеличить счетчик - curl.exe -X POST http://localhost:8080/increment
проверить сервак - curl.exe http://localhost:8080/healthz
проверить хранилище - curl.exe http://localhost:8080/readyz

можно запустисть автомт тесты scripts/check.sh