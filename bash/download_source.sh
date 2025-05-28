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
CONFIG_FILE="$SUBS_DIR/config/config.yaml"
CONFIG_EXAMPLE_FILE="$SUBS_DIR/config/config.example.yaml"
LOG_PATH="$SUBS_DIR/subs-check.log"

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

cp "$CONFIG_EXAMPLE_FILE" "$CONFIG_FILE"

cd "$SUBS_DIR" || exit 1

go build -ldflags="-X main.Version=dev -X main.CurrentCommit=local" -o subs-check

echo " subs-check 编译成功，执行方式./subs-check -f config/config.yaml"

get_tcp_port() {
  local port
  port=$(devil port list | awk '$1=="tcp" {print $3; exit}')
  if [ -n "$port" ]; then
    echo "$port"
  else
    devil port add tcp random >/dev/null 2>&1
    port=$(devil port list | awk '$1=="tcp" {print $3; exit}')
    echo "$port"
  fi
}

tcp_port=$(get_tcp_port)
echo "分配到的 TCP 端口是: $tcp_port"

if [ -f "$CONFIG_FILE" ]; then
  sed -i '' "s|^listen-port: \".*\"|listen-port: \":$tcp_port\"|" "$CONFIG_FILE"
  echo "已更新 $CONFIG_FILE 中的 listen-port 为 :$tcp_port"
else
  echo "配置文件 $CONFIG_FILE 不存在"
fi
