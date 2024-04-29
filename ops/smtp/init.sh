#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR
set -ex

if [ ! -d "node_modules" ]; then
  bun i $DIR
fi

if [ -v 1 ]; then
  HOST=$1
else
  echo "USAGE : $0 example.com"
  exit 1
fi

../ssl.sh $HOST

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if ! [ -x "$(command -v chasquid)" ]; then
  rm -rf /etc/chasquid /etc/systemd/system/chasquid* /tmp/chasquid
  cd /tmp
  git clone --depth=1 https://github.com/albertito/chasquid.git
  cd chasquid
  make
  make install-binaries
  make install-config-skeleton
  systemctl daemon-reload
  cd $DIR
fi

if ! [ -x "$(command -v setfacl)" ]; then
  apt-get install -y acl
fi

user=mail
id -u $user || useradd -s /bin/false $user
getent group $user >/dev/null || groupadd $user

setfacl -R -m u:$user:rX /mnt/www/.acme.sh

for i in dkimsign dkimverify dkimkeygen; do
  if ! [ -x "$(command -v $i)" ]; then
    go install github.com/driusan/dkim/cmd/$i@latest
  fi
done

CONF=$(../env.sh)

conf=$CONF/chasquid
rm -rf /etc/chasquid
mkdir -p $conf
ln -s $conf /etc/chasquid

cert=$conf/certs/$HOST
mkdir -p $cert
cd $cert
private=dkim_privkey.pem
if [ ! -f "$private" ]; then
  dkimkeygen
  mv private.pem $private
fi

link() {
  if [ ! -e "$2" ]; then
    ln -s /mnt/www/.acme.sh/${HOST}_ecc/$1 $2
  fi
}
link fullchain.cer fullchain.pem
link $HOST.key privkey.pem
cd ../..
d=domains/$HOST
mkdir -p $d
cd $d

if [ ! -f "aliases" ]; then
  echo -e "i: i.$HOST@gmail.com\n*: i.$HOST@gmail.com" >aliases
fi

if [ ! -f "dkim_selector" ]; then
  dkim=$(node -e "console.log(($(($(date +%s) / 86400))).toString(36))")
  echo $dkim >dkim_selector
else
  dkim=$(cat dkim_selector)
fi

rsync --ignore-existing -av $DIR/conf/ $conf
rsync --ignore-existing -av $DIR/domains/ $conf/domains/$HOST
chgrp -R $user $conf

mkdir -p /var/lib/chasquid
chown $user:$user /var/lib/chasquid

systemctl enable chasquid --now
systemctl restart chasquid
systemctl status chasquid --no-pager

set +x
green() {
  echo -e "\033[32m$1\033[0m"
}

echo -e "\nDKIM → Please Add DNS TXT : $(green $dkim._domainkey.$HOST)\n"
cat $cert/dns.txt
echo ''
