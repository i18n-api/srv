#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

PWD=$(dirname $(realpath $BASH_SOURCE))

#name=$(cat Cargo.toml | dasel -r toml package.name -w plain)
to=/etc/systemd/system/$NAME.service
cp $PWD/service $to
mkdir -p /opt/bin/
EXE=/opt/bin/$NAME
rm -rf $EXE
mv bin/$NAME $EXE
service_sh=/opt/bin/$NAME.service.sh

cat >$service_sh <<EOF
#!/usr/bin/env bash
cd $WORKDIR
export HOME=$HOME
. /etc/profile
. env.sh
exec $EXE $ARGS
EOF

sed -i "s#EXEC#${service_sh}#" $to
sed -i "s#NAME#${name}#" $to
chmod +x $service_sh
systemctl daemon-reload

systemctl enable --now $NAME
systemctl restart $NAME

systemctl status $NAME --no-pager

journalctl -u $NAME -n 10 --no-pager --no-hostname
