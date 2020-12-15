#!/bin/bash
list='kube-apiserver:v1.19.5
kube-controller-manager:v1.19.5
kube-scheduler:v1.19.5
kube-proxy:v1.19.5
pause:3.2
etcd:3.4.13-0
coredns:1.7.0'
for item in ${list}
  do

    docker pull registry.aliyuncs.com/google_containers/$item && docker tag registry.aliyuncs.com/google_containers/$item k8s.gcr.io/$item && docker rmi registry.aliyuncs.com/google_containers/$item

  done

#上面过程
#docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v1.19.5
#docker tag registry.aliyuncs.com/google_containers/kube-apiserver:v1.19.5 k8s.gcr.io/kube-apiserver:v1.19.5
#docker rmi registry.aliyuncs.com/google_containers/kube-apiserver:v1.19.5