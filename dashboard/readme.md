# 部署 Dashboard UI

默认情况下不会部署 Dashboard。可以通过以下命令部署：
```bash

bash image.sh

kubectl apply -f ./recommended.yaml

#对外暴露Dashboard
kubectl -n kubernetes-dashboard edit kubernetes-dashboard

#type: ClusterIPs
#改为
#type: NodePort

#查看svc
kubectl -n kubernetes-dashboard get svc
#看到端口3xxxx
#https://192.168.0.199:3xxxx


#翻车。。。。接下来。。。往下看。。。
```




# 自签名证书
## 生成私钥和证书签名请求
```bash
#创建SSL证书需要私钥和证书签名请求。这些可以通过一些简单的命令生成。
#当openssl req命令要求输入“密码”时，只需按回车键，将密码保留为空。
#证书颁发机构使用此密码来验证证书所有者，以撤消其证书。
#由于这是一个自签名证书，因此无法通过CRL（证书吊销列表）吊销它。
openssl genrsa -des3 -passout pass:over4chars -out dashboard.pass.key 2048

openssl rsa -passin pass:over4chars -in dashboard.pass.key -out dashboard.key

rm dashboard.pass.key

openssl req -new -key dashboard.key -out dashboard.csr
```
## 生成SSL证书
```bash
#自签名SSL证书是从dashboard.key私钥和dashboard.csr文件生成的。
openssl x509 -req -sha256 -days 365 -in dashboard.csr -signkey dashboard.key -out dashboard.crt
#该dashboard.crt文件是您的证书，适合与dashboard.key专用密钥一起用于仪表板。
```



# 配置一下证书
```bash
#删除默认创建的secret
kubectl delete secret kubernetes-dashboard-certs  -n kubernetes-dashboard
#重新创建secret，主要用来指定证书的存放路径
create secret generic kubernetes-dashboard-certs --from-file=/etc/kubernetes/pki/ -n kubernetes-dashboard
#删除dashboard的pod，主要让它重新运行，加载证书
kubectl delete pod -n kubernetes-dashboard

```
在试着访问.....
https://192.168.0.199:3xxxx
应该是成功了


# 登录
```bash

#获取token
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

把token粘贴登录，开始愉快的访问吧！