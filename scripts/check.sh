
#!/usr/bin/env bash
set -e

pr="hw3_$$_$RANDOM"
export HOST_PORT=$((20000 + RANDOM))
ur="http://127.0.0.1:$HOST_PORT"
st="запуск"

dc() {
    docker compose -p "$pr" "$@" > /dev/null 2>&1
}

trap 'dc down -v' EXIT
trap 'echo "Ошибка: $st" >&2' ERR

wt() {
    for i in {1..30}; do
        if curl -fsS --max-time 3 "$ur/readyz" > /dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    return 1
}

rq() {
    an=$(curl -sS --max-time 5 -X "$2" -w ':%{http_code}' "$ur$1") || return 1

    [[ "$an" == *":$3" ]] || return 1

    if [ "$#" -eq 4 ]; then
        [[ "$an" == *"\"count\": $4,"* ]] || return 1
    fi
}

dc up -d --build
wt

st="счётчик"
rq / GET 200 0
echo 0

for i in 1 2 3; do
    rq /increment POST 200 "$i"
done
echo 3

st="пересоздание"
dc up -d --force-recreate --no-deps app
wt
rq / GET 200 3
echo 3

st="сохранение данных"
dc down
dc up -d
wt
rq / GET 200 3
echo 3

st="отключение Redis"
dc stop redis
rq /healthz GET 200
echo 200
rq /readyz GET 503
echo 503
rq /increment POST 503
echo 503

st="восстановление Redis"
dc start redis
wt
rq / GET 200 3
echo 3
rq /increment POST 200 4
echo 4

st="резервная копия"
dc stop app redis
MSYS_NO_PATHCONV=1 docker run --rm -v "${pr}_redis_data:/data:ro" alpine:3.20 tar -czf - -C /data . > "$pr.tar.gz" 2>/dev/null
