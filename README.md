# Serv00
* 下载源码并编译为二进制文件
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/subs_check/main/bash/download_source.sh)
```
* 后台运行
```bash
nohup ./subs-check -f config/config.yaml > nohup.log 2>&1 &
```
* 上传配置文件
```bash
scp C:\Users\username\Desktop\config.yaml username@host:domains/username.serv00.net/logs/subs_check/config/
```
# Debian 12+
```bash
bash <(curl -Ls https://raw.githubusercontent.com/co2f2e/subs_check/main/bash/subs_check.sh)
```



