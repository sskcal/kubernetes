#!/bin/bash
#批量复制公匙到服务器
#记得先执行这条命令生成公匙：ssh-keygen
password=123456

for i in {200,201,202,210}
  do
    expect <<-EOF
    set timeout 5
    spawn ssh-copy-id -i root@192.168.0.$i
    expect {
    "password:" { send "$password\n" }
    }
  interact
  expect eof
EOF
done



