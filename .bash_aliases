cat << 'EOF'
Welcome to Marek's priv Docker

Dockerfile and image are intended to be used without and behind the proxy.

For proxy:
- Dockerfile::`COPY apt.conf /etc/apt/`
- .bash_aliases::exports proxies.

Without proxy:
- Dockerfile::`#COPY apt.conf /etc/apt/` (comment out)
- .bash_aliases::Prevent from exporting, eg. `if [[ ! : ]]; then <proxy>; fi`
EOF

if [[ ! : ]]; then
export https_proxy=http://proxy-us.intel.com:912
export HTTPS_PROXY=$https_proxy
export http_proxy=http://proxy-us.intel.com:911
export HTTP_PROXY=$http_proxy
export ftp_proxy=http://proxy-us.intel.com:911
export FTP_PROXY=$ftp_proxy
export socks_proxy=http://proxy-us.intel.com:1080
export SOCKS_PROXY=$socks_proxy
export no_proxy=127.0.0.1
#yocto
export GIT_PROXY_COMMAND="oe-git-proxy"
export NO_PROXY=$no_proxy
fi
