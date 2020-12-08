#!/bin/bash
list='kube-apiserver:v1.19.4
kube-controller-manager:v1.19.4
kube-scheduler:v1.19.4
kube-proxy:v1.19.4
pause:3.2
etcd:3.4.13-0
coredns:1.7.0'
for item in ${list}
  do

    docker pull registry.aliyuncs.com/google_containers/$item && docker tag registry.aliyuncs.com/google_containers/$item k8s.gcr.io/$item && docker rmi registry.aliyuncs.com/google_containers/$item

  done
#下载flannel网络插件
docker pull quay.io/coreos/flannel:v0.13.1-rc1