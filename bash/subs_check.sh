#!/bin/bash

red() { echo -e "\e[31m$1\e[0m"; }
green() { echo -e "\e[32m$1\e[0m"; }
yellow() { echo -e "\e[33m$1\e[0m"; }
blue() { echo -e "\e[34m$1\e[0m"; }

show_menu() {
  clear
  green "============SubsCheck================"
  green "1. 下载压缩并设置开机自启"
  green "2. 后台运行 subs-check"
  green "3. 终止运行"
  green "4. 停止并清除相关内容"
  green "5. 查看日志"
  green "6. 查看配置文件"
  green "0. 退出"
  green "====================================="
}
  SUBS_DIR="/subs_check"
  BINARY_NAME="subs-check"
  BINARY_PATH="$SUBS_DIR/$BINARY_NAME"
  CONFIG_FILE="$SUBS_DIR/config/config.yaml"
  LOG_PATH="$SUBS_DIR/$BINARY_NAME.log"
  CRON_CMD="cd $SUBS_DIR && ./$BINARY_NAME > $LOG_PATH 2>&1"
  LOG_FILE="$SUBS_DIR/output.log"

option_1() {
  echo
  if [ ! -d "$SUBS_DIR" ]; then
    mkdir -p "$SUBS_DIR"
    cd "$SUBS_DIR" || exit 1

    yellow "正在下载 subs-check..."
    curl -L -o ${BINARY_NAME}_Linux_x86_64.tar.gz $(curl -s https://api.github.com/repos/beck-8/subs-check/releases/latest |
      grep "browser_download_url" |
      grep "${BINARY_NAME}_Linux_x86_64.tar.gz" |
      cut -d '"' -f 4) &&
      tar -xzf ${BINARY_NAME}_Linux_x86_64.tar.gz &&
      rm ${BINARY_NAME}_Linux_x86_64.tar.gz

    chmod +x "$BINARY_NAME"
    green "下载并解压成功"
  else
    red "目录已存在，请先执行第 4 项清除"
    return
  fi

  crontab -l 2>/dev/null | grep -F "@reboot $CRON_CMD" >/dev/null
  if [ $? -ne 0 ]; then
    (
      crontab -l 2>/dev/null
      echo "@reboot $CRON_CMD"
    ) | crontab -
    green "已添加到开机自启任务"
  else
    yellow "开机自启任务已存在"
  fi
}

option_2() {
  echo
  nohup "$BINARY_PATH" >"$LOG_FILE" 2>&1 &
  green " subs-check 已在后台运行"
}

option_3() {
  echo
  pkill -f "$BINARY_NAME" && green " subs-check 已终止" || red " subs-check 未运行"
}

option_4() {
  echo
  read -p "$(red '确认清除 subs-check 及所有相关内容？(y/n): ')" confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    crontab -l | grep -v subs-check | crontab -
    pkill -f "$BINARY_NAME"
    rm -rf "$SUBS_DIR"
    green "已停止程序并清除相关内容"
  else
    yellow "取消清除操作"
  fi
}

option_5() {
  echo
  if [ -f "$LOG_FILE" ]; then
    tail -n 20 "$LOG_FILE"
  else
    red "日志文件不存在"
  fi
}

option_6() {
  if [ -f "$CONFIG_FILE" ]; then
    clear
    cat "$CONFIG_FILE"
  else
    red "配置文件不存在，请先运行一次程序，自动生成默认的配置文件"
  fi
}

while true; do
  show_menu
  read -p "$(yellow '请选择一个选项 [0-5]：')" choice
  echo ""

  case $choice in
    1) option_1 ;;
    2) option_2 ;;
    3) option_3 ;;
    4) option_4 ;;
    5) option_5 ;;
    0)
      echo ""
      green "退出脚本。"
      sleep 1
      clear
      exit 0
      ;;
    *) red "无效的选项，请重新输入。" ;;
  esac

  echo ""
  read -p "$(yellow '按 Enter 键返回主菜单...')" dummy
done
