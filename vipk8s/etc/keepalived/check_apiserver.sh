#!/bin/bash
APISERVER_VIP=192.168.0.199
APISERVER_DEST_PORT=6443
 
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}
 
curl --silent --max-time 2 --insecure https://localhost:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://localhost:${APISERVER_DEST_PORT}/"
if ip addr | grep -q ${APISERVER_VIP}; then
    curl --silent --max-time 2 --insecure https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/ -o /dev/null || errorExit "Error GET https://${APISERVER_VIP}:${APISERVER_DEST_PORT}/"
fi
#记得给此文件执行权限
#chmod +x /etc/keepalived/check_apiserver.sh

#需要修改的参数
#APISERVER_VIP 虚拟ip