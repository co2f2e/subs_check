#!/bin/bash
clear
cd /

SUBS_DIR="subs_check"
BINARY_NAME="subs-check"
CRON_CMD="cd /$SUBS_DIR && ./subs-check > subs-check.log 2>&1 &"

if [ ! -d "$SUBS_DIR" ]; then
  mkdir "$SUBS_DIR"
  cd "$SUBS_DIR" || exit 1

  curl -L -o ${BINARY_NAME}_Linux_x86_64.tar.gz $(curl -s https://api.github.com/repos/beck-8/subs-check/releases/latest \
    | grep "browser_download_url" \
    | grep "${BINARY_NAME}_Linux_x86_64.tar.gz" \
    | cut -d '"' -f 4) \
  && tar -xzf ${BINARY_NAME}_Linux_x86_64.tar.gz \
  && rm ${BINARY_NAME}_Linux_x86_64.tar.gz

  chmod +x "$BINARY_NAME"
  echo "下载并解压成功，请修改配置文件 config.yaml 然后执行下面命令后台运行二进制文件，日志文件位于 subs-check.log "
  echo "nohup ./subs-check > output.log 2>&1 &"
else
  cd "$SUBS_DIR" || exit 1
  echo "目录已存在，跳过下载解压"
fi

crontab -l 2>/dev/null | grep -F "$CRON_CMD" >/dev/null
if [ $? -ne 0 ]; then
  (crontab -l 2>/dev/null; echo "@reboot $CRON_CMD") | crontab -
  echo "已添加到开机自启任务"
else
  echo "开机自启任务已存在"
fi
