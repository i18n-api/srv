set -o allexport
RUST_BACKTRACE=short

RUST_LOG=debug,supervisor=warn,hyper=warn,rustls=warn,h2=warn,tower=warn,reqwest=warn,watchexec=warn,fred=info,globset=warn,process_wrap=warn,tungstenite=warn,grep_regex=warn,cargo_machete=warn

_init() {
  cd $1
  shift
  for i in $@; do
    set -o allexport
    . "$i".sh
    set +o allexport
  done
  cd ..
}

_init srv port env token
_init env stripe db smtp r ipv6_proxy warn_mail

set +o allexport
unset -f _init
