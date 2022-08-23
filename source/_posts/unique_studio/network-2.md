---
title: 联创计网笔记2——总体架构
date: 2019-11-26 11:00:27
tags:
- 网络
- 联创
categories:
- 网络
---
记得做好数据持久化，比如/etc/quagga/daemon里ospfd=yes

<!--more-->

# hust部分
HUST-LYJ IP 202.114.12.2/24
HUST-USER1 IP 202.114.12.3/24
HUST-USER2 IP 自动分布
HUST-ROUTER-USER 对学生 202.114.12.4/24
HUST-ROUTER-USER 对border 202.114.9.254/24
HUST-ROUTER 对学生 202.114.12.6/24
HUST-ROUTER 对服务 202.114.10.3/24
HUST-ROUTER 对border 202.114.9.3/24
HUST-HUB IP 202.114.10.2/24
在HUST-ROUTER HUST-ROUTER-USER 上开ospf。
注意HUST-ROUTER-USER的ospf只有user的！没有border。
注意手动删掉HUST-ROUTER-USER里ip route的202.114.12.0/24 src为 202.114.12.254那个，不然全白给。
HUST-ROUTER-USER-WIRELESS 对外ip 202.114.12.7/24
HUST-ROUTER-USER-WIRELESS 对内ip 10.1.1.2/24

把hust-lyj那几个的ip route 的default统统搞到他对接的那个端口去（ip route replace default via 202.114.12.4之类的）

HUST-ROUTER-USER-WIRELESS 安装好iptables和dhcp直接自己搞一个镜像commit一下。

（小型测试网络：A-B-C，添加网关为B上相应的端口 route add default gw xx.xx.xx.xx/yy能ping通服务器上另几个端口（user2 ping wireless其他端口可），然后路由转发都打开，就双向ping通了。

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE，eth0是外网端口，ip出去的全伪装成外网端口出去的了。
要开nat后头dhcp分配完10.几的ip以后才能ping出去
dnsmasq搞了dhcp
HUST-ROUTER-USER-WIRELESS里头/etc/dnsmasq.conf
```
port=5353（有占用就换）
interface=eth1
dhcp-range=10.1.1.20,10.1.1.240,12h
dhcp-option=3,10.1.1.2
```
然后dnsmasq
网上复制一份/usr/share/udhcpc/default.script于HUST-USER2，然后udhcpc就自动获得了ip
（别忘了增加执行权限
# WHU部分
WHU-ROUTER 对border 202.114.64.254/24
WHU-ROUTER 对内 202.114.65.2/24
WHU-USER1 192.168.30.3/24
WHU-USER2 192.168.30.4/24
WHU-STUDENT-NAT 对内 192.168.30.2/24
WHU-STUDENT-NAT 对外 202.114.65.3/24
WHU-DB 202.114.t65.4/24
WHU-WWW 202.114.65.5/24
WHU-BAKCUP 202.114.65.6/24
WHU-BAKCUP的ftp用户为www，密码123456
```
pure-pw useradd user1 -u ftpuser -g ftpgroup -d /var/www/site1
pure-pw mkdb
/etc/init.d/pure-ftpd restart
```

# GOOGLE部分
GOOGLE-ROUTER 对外ip 8.8.7.3/24
GOOGLE-ROUTER 对内 8.8.8.3/24
GOOGLE-DNS 8.8.8.8/24
GOOGLE-VPNSERVER 对外8.8.8.9/24

# NAIVEKUN
对外210.173.0.2/24

# 运营商
CHN-MOBILE-BGP-10087 对 HUST-BORDER 202.114.9.5/24
CHN-UNICOM-BGP-10010 对 GOOGLE-BORDER 8.8.7.2/24
CHN-MOBILE-BGP-10086 对 WHU-BORDER 202.114.64.4/24
NAIVEKUN-TELECOM-BGP-23333 对 NAIVEKUN-BORDER 210.173.0.4/24

CHN-MOBILE-BGP-10087 对 CHN-UNICOM-BGP-10010 10.233.251.2/30
CHN-UNICOM-BGP-10010 对 CHN-MOBILE-BGP-10087 10.233.251.1/30
CHN-UNICOM-BGP-10010 对 NAIVEKUN-TELECOM-BGP-23333 10.233.253.1/30
NAIVEKUN-TELECOM-BGP-23333 对 CHN-UNICOM-BGP-10010 10.233.253.2/30
CHN-UNICOM-BGP-10010 对 CHN-MOBILE-BGP-10086 10.233.252.1/30
CHN-MOBILE-BGP-10086 对 CHN-UNICOM-BGP-10010 10.233.252.2/30
CHN-MOBILE-BGP-10086 对 NAIVEKUN-TELECOM-BGP-23333 10.233.254.2/30
NAIVEKUN-TELECOM-BGP-23333 对 CHN-MOBILE-BGP-10086 10.233.254.1/30
//01001111
# BGP配置
[参考](https://linux.cn/article-4609-1.html)

注意，单纯的neighbor只是一跳，要想天
2xx.x.x.2/30
1010.0101.1010.00000010
