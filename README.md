# Serv00
* 下载源码并编译为二进制文件
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/subs_check/main/bash/download_source.sh)
```
# Debian 12+
* 下载解压并开机自启
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/subs_check/main/bash/download.sh)
```
* 后台运行
```bash
nohup /subs_check/subs-check > /subs_check/output.log 2>&1 &
```
* 终止运行
```bash
pkill -f subs-check 
```
* 删除开机自启
```bash
crontab -l | grep -v subs-check | crontab -
```
* 查看最新日志
```bash
tail -f /subs_check/output.log
```


