#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ ! -f "mnt/ssl/127.0.0.1-key.pem" ]; then
  mkdir -p mnt/ssl
  cd mnt/ssl
  bun x mkcert 127.0.0.1
  cd $DIR
fi

direnv exec . ./gen.coffee
direnv exec . docker-compose up -d

p=""
set +x
while true; do
  docker-compose exec db true || (echo -e '\nERROR on start db\n' && docker-compose logs -n20 db && exit 1)
  echo "select 1;" | mysql -h 127.1 -P$MYSQL_PORT -u $MYSQL_USER $MYSQL_DB >/dev/null 2>&1 && break || true
  s=$(docker-compose logs db -n1)
  if [ "$p" != "$s" ]; then
    echo "WAIT MYSQL: $s"
    p=$s
  fi
  sleep 1
  echo -n ·
done
set -x
echo "\n"
docker-compose logs -n6
echo -e "\n"
docker-compose ps --format "{{.State}} | {{.Name}} | {{.Image}} | {{.Ports}}"
