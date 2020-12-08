# 安装kubernetes集群

## 安装前准备
1、准备3台，2G或更大内存，2核或以上CPU，30G以上硬盘 物理机或云主机或虚拟机

## 环境准备

```shell

#根据规划设置主机名
hostnamectl set-hostname master01
hostnamectl set-hostname node01
hostnamectl set-hostname node02

#在master添加hosts
cat >> /etc/hosts << EOF
192.168.0.200 master01
192.168.0.201 node01
192.168.0.202 node02
EOF

#设置免登录
ssh-keygen
ssh-copy-id root@node01
ssh-copy-id root@node02

#关闭防火墙
systemctl stop firewalld && systemctl disable firewalld

#关闭selinux
sed -i 's/enforcing/disabled/' /etc/selinux/config && setenforce 0

#关闭swap
swapoff -a && sed -ri 's/.*swap.*/#&/' /etc/fstab


#时间同步
yum install ntpdate -y && ntpdate time.windows.com

```

## 安装Docker
```shell
# step 1: 安装必要的一些系统工具
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3: 更新并安装Docker-CE
sudo yum makecache fast
sudo yum -y install docker-ce
# Step 4: 开启Docker服务
sudo systemctl start docker && systemctl enable docker

# 注意：
# 官方软件源默认启用了最新的软件，您可以通过编辑软件源的方式获取各个版本的软件包。例如官方并没有将测试版本的软件源置为可用，您可以通过以下方式开启。同理可以开启各种测试版本等。
# vim /etc/yum.repos.d/docker-ee.repo
#   将[docker-ce-test]下方的enabled=0修改为enabled=1
#
# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# yum list docker-ce.x86_64 --showduplicates | sort -r
#   Loading mirror speeds from cached hostfile
#   Loaded plugins: branch, fastestmirror, langpacks
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            docker-ce-stable
#   docker-ce.x86_64            17.03.1.ce-1.el7.centos            @docker-ce-stable
#   docker-ce.x86_64            17.03.0.ce-1.el7.centos            docker-ce-stable
#   Available Packages
# Step2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.0.ce.1-1.el7.centos)
# sudo yum -y install docker-ce-[VERSION]

# docker镜像加速，"https://s2q9fn53.mirror.aliyuncs.com"这个地址建议自己登陆阿里云，在容器镜像服务中找到。
# 可以通过修改daemon配置文件/etc/docker/daemon.json来使用加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://s2q9fn53.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload && sudo systemctl restart docker
```

## 安装kubelet、kubeadm、kubectl

- kubeadm：用来初始化集群的指令。
- kubelet：在集群中的每个节点上用来启动 pod 和容器等。
- kubectl：用来与集群通信的命令行工具。

kubeadm 不能 帮您安装或者管理 kubelet 或 kubectl，所以您需要确保它们与通过 kubeadm 安装的控制平面的版本相匹配。 如果不这样做，则存在发生版本偏差的风险，可能会导致一些预料之外的错误和问题。 然而，控制平面与 kubelet 间的相差一个次要版本不一致是支持的，但 kubelet 的版本不可以超过 API 服务器的版本。 例如，1.7.0 版本的 kubelet 可以完全兼容 1.8.0 版本的 API 服务器，反之则不可以。

```shell
#添加kubernetes阿里YUM源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet-1.19.4 kubeadm-1.19.4 kubectl-1.19.4 && systemctl enable kubelet && systemctl start kubelet

```

## 部署Kubernetes Master
在192.168.0.200（Master）执行
```shell

#注意，kubeadm init 前,先准备k8s运行所需的容器
#可查询到kubernetes所需镜像
kubeadm config images list

#写了个sh脚本，把所需的镜像拉下来
cat >> alik8simages.sh << EOF
#!/bin/bash
list='kube-apiserver:v1.19.4
kube-controller-manager:v1.19.4
kube-scheduler:v1.19.4
kube-proxy:v1.19.4
pause:3.2
etcd:3.4.13-0
coredns:1.7.0'
for item in \$list
  do

    docker pull registry.aliyuncs.com/google_containers/\$item && docker tag registry.aliyuncs.com/google_containers/\$item k8s.gcr.io/\$item && docker rmi registry.aliyuncs.com/google_containers/\$item

  done
EOF
#运行脚本下载
bash alik8simages.sh



#初始化k8s集群
kubeadm init \
--apiserver-advertise-address=192.168.0.200 \
--kubernetes-version=v1.19.4 \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16

#提示initialized successfully!表示初始化成功
##注意提示：to start using you cluster,you need to run the following as a regular user:
mkdir -p ...
sudo cp ...
sudo chown ...
#按提示执行以上三条命令
#执行完后可以运行,查看node节点情况
kubectl get nodes

#还有一条提示：
#then you can join any number of worker nodes by running the following on each as root
#翻译：然后，您可以通过在每个worker节点上以root身份运行以下命令来连接任意数量的worker节点
#接着把提示如下的语句复制到node节点运行
kubeadm join 192.168.1.200:6443 --token ...
```
#### 部署CNI网络插件

```shell

#下载flannel网络插件
docker pull quay.io/coreos/flannel:v0.13.1-rc1

kubectl apply -f kube-flannel.yml
```
