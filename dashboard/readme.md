# 部署 Dashboard UI

## 视频教程(部署 Dashboard UI)
https://www.bilibili.com/video/BV1Az4y1k7nn/

默认情况下不会部署 Dashboard。可以通过以下命令部署：
```bash

bash image.sh

kubectl apply -f ./recommended.yaml

#对外暴露Dashboard
kubectl -n kubernetes-dashboard edit svc kubernetes-dashboard

#type: ClusterIPs
#改为
#type: NodePort

#查看svc
kubectl -n kubernetes-dashboard get svc
#看到端口3xxxx
#https://192.168.0.199:3xxxx


```







# 配置一下证书
```bash
#删除默认创建的secret
kubectl delete secret kubernetes-dashboard-certs  -n kubernetes-dashboard
#重新创建secret，主要用来指定证书的存放路径
kubectl create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/pki/ -n kubernetes-dashboard
#删除dashboard的pod，主要让它重新运行，加载证书
kubectl delete pod -n kubernetes-dashboard --all

```
在试着访问.....
https://192.168.0.199:3xxxx
应该是成功了


# 登录
```bash
#创建服务账户
kubectl apply -f ./dashboard-adminuser.yaml
#创建一个ClusterRoleBinding
kubectl apply -f ./dashboard-ClusterRoleBinding.yaml

#获取token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

把token粘贴登录，开始愉快的访问吧！