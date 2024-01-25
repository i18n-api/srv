export RUSTFLAGS='--cfg reqwest_unstable -C target-feature=+aes'
export RUST_BACKTRACE=short
export RUST_LOG=debug,supervisor=warn,hyper=warn,rustls=warn,h2=warn,tower=warn,reqwest=warn,watchexec=warn,fred=info,globset=warn
