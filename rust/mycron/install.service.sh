#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

./build.sh

name=$(cat Cargo.toml | dasel -r toml package.name -w plain)

to=/etc/systemd/system/$name.service
cp ./service $to
mkdir -p /opt/bin/
EXE=/opt/bin/$name
mv bin/$name $EXE
service_sh=/opt/bin/$name.service.sh

cat >$service_sh <<EOF
#!/usr/bin/env bash
DIR=$(dirname $(dirname $DIR))
cd $DIR
source env.sh
exec $EXE $DIR/mod
EOF

sed -i "s#EXEC#${service_sh}#" $to
sed -i "s#NAME#${name}#" $to

systemctl daemon-reload

systemctl enable --now $name
systemctl restart $name

systemctl status $name --no-pager

journalctl -u $name -n 10 --no-pager --no-hostname
