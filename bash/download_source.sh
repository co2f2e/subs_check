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
echo
echo "注意：分配到的 TCP 端口是: $tcp_port，请修改 config.yaml 中的 listen-port 为该端口。"

go build -ldflags="-X main.Version=dev -X main.CurrentCommit=local" -o subs-check

echo
echo "二进制文件 subs-check 编译成功，拷贝并重命名 config.example.yaml为config.yaml 到 config 目录下，配置参考该目录下的配置模板 config.example.yaml，然后在 subs_check 目录下执行 nohup ./subs-check -f config/config.yaml > subs-check.log 2>&1 &
后台运行程序。"

# 二进制文件运行，删除不必要的源码文件
rm -rf app check doc Dockerfile go.mod go.sum init.go LICENSE main.go Makefile proxy README.md save util
