#!/bin/bash

USERNAME="beiyuqu"
[ $1 ] && USERNAME=$1

SSH_FILT="/root/.ssh"
SSH_KEYS="${SSH_FILT}/authorized_keys"
SSH_CFG="/etc/ssh/sshd_config"

[ -d $SSH_FILT ] || mkdir $SSH_FILT

if [ -e $SSH_KEYS ];then
    read -p "$SSH_KEYS 公钥已经存在是否覆盖？(y/N)" yn
    [[ ${yn,,} =~ ^y ]] && wget -q "https://github.com/${USERNAME}.keys" -O "$SSH_KEYS"
else
    wget -q "https://github.com/${USERNAME}.keys" -O "$SSH_KEYS"
fi

chmod 700 "${SSH_FILT}/authorized_keys"
chmod 600 ${SSH_FILT}

# 启用密码登录
sed -i "/^#*PasswordAuthentication/cPasswordAuthentication no" "$SSH_CFG"
# 启用root账号密码登录
sed -i "/^#*PermitRootLogin/cPermitRootLogin yes" "$SSH_CFG"
# 允许rsa数字证书
sed -i "/^#*RSAAuthentication/cRSAAuthentication yes" "$SSH_CFG"
# 公钥验证
sed -i "/^#*PubkeyAuthentication/cPubkeyAuthentication yes" "$SSH_CFG"

/etc/init.d/ssh restart

echo "设置完成！"
