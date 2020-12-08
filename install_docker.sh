#!/bin/bash
sudo yum install -y yum-utils device-mapper-persistent-data lvm2 && /
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && /
sudo yum makecache fast && /
sudo yum -y install docker-ce && /
sudo systemctl start docker && systemctl enable docker
