#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
. ./env.sh

HOST=$1

export HOME=/opt/www
export LE_WORKING_DIR=$HOME/acme
ACME_DIR=$LE_WORKING_DIR
acme="$ACME_DIR/acme.sh"

ACME_DIR_ENV=$ACME_DIR/acme.sh.env

conf=$CONF/ssl.sh
set -o allexport
source $conf
set +o allexport

arg="--server zerossl"

if [ ! -x "$acme" ]; then
  if ! curl -I --connect-timeout 1 -m 3 -s https://t.co >/dev/null; then
    GHPROXY=https://ghproxy.com/
  fi
  cd /tmp
  curl ${GHPROXY}https://raw.githubusercontent.com/usrtax/acme.sh/master/acme.sh | sh -s -- --install-online --email $MAIL
  $acme $arg --register-account --accountemail $MAIL
  $acme --upgrade --auto-upgrade
fi

if [ ! $DNS ]; then
  echo -e "\nPLEASE EDIT :\n$conf\n"
  exit 1
fi

if [ -z "$HOST" ]; then
  echo "USAGE : $0 example.com"
  exit 1
fi

set -ex

# export DEBUG=1

mkdir -p $CONF/ssl/reload

reload="$CONF/ssl/reload/$HOST.sh"

if [ ! -f "$reload" ]; then
  cp $DIR/ssl/reload.sh $reload
  cd $CONF
  git add $reload
  git commit -m "add ssl reload"
  cd $DIR
fi

fullchain=$HOME/.acme.sh/${HOST}_ecc/fullchain.cer

gen() {
  if [ -f "$fullchain" ]; then
    echo "update $HOST"
    # 获取文件的修改时间并将其转换为 UNIX 时间戳
    file_modified_time=$(stat -c %Y "$fullchain")
    # 获取当前时间的 UNIX 时间戳
    current_time=$(date +%s)
    # 计算文件修改时间和当前时间之间的时间差
    time_diff=$((current_time - file_modified_time))
    # 如果时间差小于一天的秒数，则文件在一天内被修改过
    if [ "$time_diff" -lt 86400 ]; then
      echo "$fullchain updated today"
    else
      $acme \
        $arg \
        --force --renew \
        -d $HOST -d *.$HOST \
        --reloadcmd "$reload"
    fi
  else
    echo "init $HOST"
    $acme \
      $arg \
      --dns dns_$DNS \
      --days 30 --issue \
      -d $HOST -d *.$HOST \
      --reloadcmd "$reload"
  fi
}

gen || gen

if command -v apt-get &>/dev/null; then
  if ! [ -x "$(command -v setfacl)" ]; then
    apt-get install -y acl
  fi

  can_read() {
    id -u $1 &>/dev/null && setfacl -R -m u:$1:rX $ACME_DIR
  }

  can_read www-data
  can_read mail
fi
