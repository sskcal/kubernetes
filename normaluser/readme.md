

# 给kubernetes(k8s)创建一个普通用户！

创建一个用户太容易了，是吧?

不过我相信很多人看完官方文档都不一定能创建一个kubernetes集群用户！

官方文档地址：https://v1-19.docs.kubernetes.io/zh/docs/reference/access-authn-authz/certificate-signing-requests/#normal-user


## 普通用户
kubernetes用户有2种，一种是账户，另一种是服务账户！我们这里来创建的是账户！
为了让普通用户能够通过认证并调用 API，需要执行几个步骤。 首先，该用户必须拥有 Kubernetes 集群签发的证书， 然后将该证书作为 API 调用的 Certificate 头或通过 kubectl 提供。

### 创建私匙

下面的脚本展示了如何生成 PKI 私钥和 CSR。 设置 CSR 的 CN 和 O 属性很重要。CN 是用户名，O 是该用户归属的组。

```shell
openssl genrsa -out john.key 2048
openssl req -new -key john.key -out john.csr -subj "/CN=john/O=ops"
```

### 创建 CertificateSigningRequest
创建一个 CertificateSigningRequest，并通过 kubectl 将其提交到 Kubernetes 集群。 下面是生成 CertificateSigningRequest 的脚本。


```shell

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: john
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1lqQ0NBVW9DQVFBd0hURU5NQXNHQTFVRUF3d0VhbTlvYmpFTU1Bb0dBMVVFQ2d3RGIzQnpNSUlCSWpBTgpCZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUExSUxhNEY1MFk2ZUgzNTlhTjRYeS9TbG95MTFWCjUvNDNmdXZQWTRESFJPQXkvUTVLaTN4WGhqbkt4RXcvcXd1QVpjMFF2YmZwVm1iZGhmVnMyZnc4WlA2TzgzTEQKZS8xQ25DTVdXaUlvZi84ZmVTZ1dFQkN1Y1pudm5XUU13ZnJQY3NmMHVCWU1nank4MkpQV3VnQ1NlZ1dNUHhLZgpGWXNQNGd0SnZwblN6cC9PczNwV0E4OVJsTm0zTmRSS0hNRUJZMnZqcHc4YUhHYXE5Y2tPbEJ0OWlkcjA5U2RMCkthVVlPTy90TVdha0RqM2grVVdoYjU2N2xlcG1ERS9Rb0l3WU96VGE4a1UyaTZ0d2w4TFkweERIWVRYRjRZQVMKblZQNFdKTVpyUzBJKzZ0dmVoNTZUN3JtZmx2NkpGWDRQUThBMTFTaTJCT1g4T2pEMW1ZaTBWN1dWd0lEQVFBQgpvQUF3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUJ1bFp0M2ZtZ3pZNk5tNGh5MnBxNFk5QTJYN0xTQnZINmtZClExM1hSK2FzL2VBTlRiNHNLRzBHS05HVEhRdW1la1p5NkY4N2oyWEs0MGhvOWhYZFNDemxmZTQ3S3B0UWpxNXUKazhCTEpyZCtXbXRYY2VMTlZwTm43amU2ZWxnK1N3U2kxOUMrTkFvTk42ODAxdGlwNVNlcEFOMW9vVk54NDBHcApHa01aQmY5TkEzWnk0alplTlR6cnFmdUJIem43SEVJWDBYbzV2em5SRW1rUnpuMUJNZUlVd0lMZncwMC9mM3FqClVyUzFOMWNtZkN0ZkR3aEVLaWZ0di96NmYwVlVkVXBvY2FvdnJwVlAwRUFjQzhnMWNTQ3ZncEk5UUVsODl3ckkKVmh1K0VqSEFLZ3hqTXNUUnFOWkhDeE9UWTNwWlBiZzRmRm9zWmtGQWZsVlFyQTZWMkUwPQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

```

### 批准证书签名请求


使用 kubectl 创建 CSR 并批准。

获取 CSR 列表：

```shell
kubectl get csr
```

批准 CSR：
```shell
kubectl certificate approve john
```

### 取得证书

从 CSR 取得证书：

```shell

kubectl get csr/john -o yaml
# 根据上面命令取得status.certificate字段的base64加密的值
#通过下面的命令解密 导出john.crt证书
echo "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURBakNDQWVxZ0F3SUJBZ0lRVE9DNW9YZkY4eEJqS1lxalFjUy9lakFOQmdrcWhraUc5dzBCQVFzRkFEQVYKTVJNd0VRWURWUVFERXdwcmRXSmxjbTVsZEdWek1CNFhEVEl4TURFd01UQXpNemt6T0ZvWERUSXlNREV3TVRBegpNemt6T0Zvd0hURU1NQW9HQTFVRUNoTURiM0J6TVEwd0N3WURWUVFERXdScWIyaHVNSUlCSWpBTkJna3Foa2lHCjl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUExSUxhNEY1MFk2ZUgzNTlhTjRYeS9TbG95MTFWNS80M2Z1dlAKWTRESFJPQXkvUTVLaTN4WGhqbkt4RXcvcXd1QVpjMFF2YmZwVm1iZGhmVnMyZnc4WlA2TzgzTERlLzFDbkNNVwpXaUlvZi84ZmVTZ1dFQkN1Y1pudm5XUU13ZnJQY3NmMHVCWU1nank4MkpQV3VnQ1NlZ1dNUHhLZkZZc1A0Z3RKCnZwblN6cC9PczNwV0E4OVJsTm0zTmRSS0hNRUJZMnZqcHc4YUhHYXE5Y2tPbEJ0OWlkcjA5U2RMS2FVWU9PL3QKTVdha0RqM2grVVdoYjU2N2xlcG1ERS9Rb0l3WU96VGE4a1UyaTZ0d2w4TFkweERIWVRYRjRZQVNuVlA0V0pNWgpyUzBJKzZ0dmVoNTZUN3JtZmx2NkpGWDRQUThBMTFTaTJCT1g4T2pEMW1ZaTBWN1dWd0lEQVFBQm8wWXdSREFUCkJnTlZIU1VFRERBS0JnZ3JCZ0VGQlFjREFqQU1CZ05WSFJNQkFmOEVBakFBTUI4R0ExVWRJd1FZTUJhQUZMUy8KcDQ5V2JDS1ZOcXlMSW5lOFFZTlFEcU82TUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCQVFBUUxsZmE2NHFTWXFuVApPRDRZSDhKUVdZd0dqK0ZwakFKbnBldWx6eVNLRmVSUXZHRUpFR1FsdTNXVURmakZaU0JPK1d3L3UzZUhFUml1Ckp3dy8zUnJUYmFtb3lEMDU2M3AxYWlWaENQdFFqMnRWZUdhSzlwQlRBZzV2OW91NmtnaEJ1Z096UXFYWWRPY1kKV0labEF6UTdlS05KWFZUWWt4V2hxK3p6V1JqektRc0lWUm9oR2dnU1RTSjNOMjlydUV2c2ljSFJLZDBtZUpYdwpVK0ZpaVVKY2QyaGVJUmtEMll2TnRreXBFZThuTWJFeUZTYjNMVE1ISkpNekNYMTBjbGFPdzFKYlNvRjE3NzN4CmxvT0pQTnowR3hGNlAyakpScHhUd093T3ZrZ3M4VXlmMlVleG81RHVuTUtTdzYrTHJXVmFHN2pRSHNYUG1JUWIKVnRpWTNMTXIKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=" | base64 -d > john.crt
```

### 创建角色和角色绑定

创建了证书之后，为了让这个用户能访问 Kubernetes 集群资源，现在就要创建 Role 和 RoleBinding 了。

下面是为这个新用户创建 Role 的示例脚本：

```shell
kubectl create role developer --verb=create --verb=get --verb=list --verb=update --verb=delete --resource=pods
```

下面是为这个新用户创建 RoleBinding 的示例命令：

```shell
kubectl create rolebinding developer-binding-john --role=developer --user=john
```

### 添加到 kubeconfig 
最后一步是将这个用户添加到 kubeconfig 文件。 我们假设私钥和证书文件存放在 “/root/cert/” 目录中。

首先，我们需要添加新的凭据：

```shell
kubectl config set-credentials john --client-key=/root/cert/john.key --client-certificate=/root/cert/john.crt --embed-certs=true

```

然后，你需要添加上下文：
```shell
kubectl config set-context john --cluster=kubernetes --user=john
```
来测试一下，把上下文切换为 john：
```shell
kubectl config use-context john
```