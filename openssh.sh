#https://github.com/peng4740/gcpopenssh/blob/master/README.md

#默认设置root密码为1234qwer

#sshd_config配置文件备份
cp /etc/ssh/sshd_config > /etc/ssh/sshd_config.bak

#修改配置
#允许ROOT密码登录
sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
#保持SSH不掉线
sed -i "s|#ClientAliveInterval 0|ClientAliveInterval 60|" /etc/ssh/sshd_config
sed -i "s|#ClientAliveCountMax 3|ClientAliveCountMax 3|" /etc/ssh/sshd_config

#重启SSH
service ssh restart && service sshd restart && systemctl restart ssh && systemctl restart sshd && /etc/init.d/ssh restart && /etc/init.d/sshd restart

#设置root密码
echo root:${1:-1234qwer} | chpasswd
