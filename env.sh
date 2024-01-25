local pwd=$(pwd)
local dir=$(readlink -f "$BASH_SOURCE")
local conf=${dir%/*/*}/conf
_init() {
  local i
  for i in $@; do
    set -o allexport
    source "$i".sh
    set +o allexport
  done

  cd $pwd
}
cd $conf/srv
_init port
cd $conf/env
_init stripe db smtp r ipv6_proxy warn_mail
unset -f _init
