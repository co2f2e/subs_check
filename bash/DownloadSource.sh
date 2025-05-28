#!/bin/sh
clear

USERNAME=$(whoami)
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == "s1.ct8.pl" ]]; then
    WORKDIR="domains/${USERNAME}.ct8.pl/logs"
else
    WORKDIR="domains/${USERNAME}.serv00.net/logs"
fi

cd $"WORKDIR"

SUBS_DIR="$WORKDIR/subs_check"
REPO_URL="https://github.com/beck-8/subs-check.git"
CONFIG_FILE="$WORKDIR/$SUBS_DIR/config.yaml"
LOG_PATH="$WORKDIR/$SUBS_DIR/subs-check.log"

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

if [ -f "$CONFIG_FILE" ]; then
  echo "开始执行 subs-check ..."
  cd "$SUBS_DIR" || exit 1
  go run main.go -f "$CONFIG_FILE" > "$LOG_PATH" 2>&1
  echo "执行完成，日志记录于 $LOG_PATH"
else
  echo "配置文件 $CONFIG_FILE 不存在，请先创建"
fi
