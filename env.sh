_init() {
  cd $1
  shift
  for i in $@; do
    . "$i".sh
  done
  cd ..
}
_init srv port
_init env stripe db smtp r ipv6_proxy warn_mail
unset -f _init
