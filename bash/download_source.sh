#!/bin/sh
clear
cd ~

USERNAME=$(whoami)
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "s1.ct8.pl" ]]; then
    WORKDIR="domains/${USERNAME}.ct8.pl/logs"
else
    WORKDIR="domains/${USERNAME}.serv00.net/logs"
fi

SUBS_DIR="$WORKDIR/subs_check"
REPO_URL="https://github.com/beck-8/subs-check.git"
CONFIG_EXAMPLE_FILE="$SUBS_DIR/config/config.example.yaml"
CONFIG_FILE="$SUBS_DIR/config/config.yaml"

if ! command -v go >/dev/null 2>&1; then
  echo "未检测到 Go，正在安装..."
  pkg install -y go
fi

if ! command -v git >/dev/null 2>&1; then
  echo "未检测到 Git，正在安装..."
  pkg install -y git
fi

if [ ! -d "$SUBS_DIR" ]; then
  git clone "$REPO_URL" "$SUBS_DIR"
else
  echo "项目目录已存在，尝试更新源码..."
  cd "$SUBS_DIR" && git pull
fi

cd "$SUBS_DIR" || exit 1

get_tcp_port() {
  local port
  port=$(devil port list | awk '$2=="tcp" {print $1; exit}')
  if [ -n "$port" ]; then
    echo "$port"
  else
    devil port add tcp random subs-check >/dev/null 2>&1
    port=$(devil port list | awk '$2=="tcp" {print $1; exit}')
    echo "$port"
  fi
}

tcp_port=$(get_tcp_port)

go build -ldflags="-X main.Version=dev -X main.CurrentCommit=local" -o subs-check

mv "$CONFIG_EXAMPLE_FILE" "$CONFIG_FILE" 
echo
echo "-----------------------------------------------------------------------------------"
echo "二进制文件 subs-check 编译成功，请修改配置文件 config.yaml"
echo "注意：分配到的 TCP 端口是: $tcp_port，请修改 config.yaml 中的 listen-port 为该端口"
echo "在 subs_check 目录下执行 nohup ./subs-check -f config/config.yaml > output/subs-check.log 2>&1 & 后台运行程序"
echo "-----------------------------------------------------------------------------------"

rm -rf app check doc Dockerfile go.mod go.sum init.go LICENSE main.go Makefile proxy README.md save utils assets
