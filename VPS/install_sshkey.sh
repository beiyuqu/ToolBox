#!/bin/bash

# 用于新装系统
# 自动配置SSH公钥登录，禁用密码登录
# 时间: 2020年11月28日15点13分


# ==================默认参数常量=======================
USERNAME=beiyuqu
PORT=13145

PATH_CURR=`pwd`


if apt --help >/dev/null 2>&1; then
    COMMOD='apt'
elif yum --help >/dev/null 2>&1; then
    COMMOD='yum'
else
    echo '仅支持apt、yum安装软件'
    exit 1
fi

# 依赖软件
COMMOD update -y && COMMOD upgrade -y
COMMOD install curl -y

clear

cd ~
[ -d .ssh ] || mkdir .ssh 
cd .ssh
curl https://github.com/$USERNAME.keys > authorized_keys
chmod 700 authorized_keys
chmod 600 ../.ssh

cd /etc/ssh/
# 启用密码验证
sed -i "/PasswordAuthentication no/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication no/c RSAAuthentication yes" sshd_config
# 公钥验证
sed -i "/PubkeyAuthentication no/c PubkeyAuthentication yes" sshd_config
sed -i "/PasswordAuthentication yes/c PasswordAuthentication no" sshd_config
sed -i "/RSAAuthentication yes/c RSAAuthentication yes" sshd_config
sed -i "/PubkeyAuthentication yes/c PubkeyAuthentication yes" sshd_config
# 端口修改
sed -i "/Port 22/c Port `$Port`" sshd_config

service sshd restart
service ssh restart
systemctl restart sshd
systemctl restart ssh

cd $PATH_CURR
rm -rf $0

echo '=========================
        禁用密码登录 yes
        启用公钥登录 yes
        修改端口$PORT yes
=========================='