---
title: 联创计网笔记1——OSPF
date: 2019-11-23 14:34:04
tags:
- 网络
- 联创
categories:
- 网络
---
docker实现OSPF测试通信（以下内容复制自网络并根据实际情况修改）

<!--more-->

docker-compose.yml
```yaml
version: '2.0'

services:              
    SITE-A:
        image: iwaseyusuke/quagga
        container_name: SITE-A
        networks:
            - TEST-NET
            - SUBNET-A
        entrypoint: sh -c "service quagga start && tail -f /dev/null"
        privileged: true

    SITE-B:
        image: iwaseyusuke/quagga
        container_name: SITE-B
        networks:
            - TEST-NET
            - SUBNET-B
        entrypoint: sh -c "service quagga start && tail -f /dev/null"
        privileged: true


networks:
    TEST-NET:
      driver: bridge
    SUBNET-A:
      driver: bridge
    SUBNET-B:
      driver: bridge
```
执行docker-compose up -d于存放该yaml的文件夹。


![net](https://files.jb51.net/file_images/article/201410/201410100911302.jpg)

我们的设备位于这条专用链路的两端。下面提供了IP地址的信息信息。

Site-A：192.168.1.0/24

Site-B：172.16.1.0/24

两个Linux设备之间的对等：10.10.10.0/30

Quagga软件包含有几个协同运行的后台程序。我们在本教程中将着重介绍设置下列后台程序。

Zebra：核心后台程序，负责内核接口和静态路由。

Ospfd：IPv4 OSPF后台程序。

## 第一个阶段：配置Zebra

我们首先创建一个Zebra配置文件，然后启动Zebra后台程序。要是已经启动了就不用了。

这里的路径可能不一样，要自己找。
```bash
cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf
/usr/lib/quagga/zebra -d
```

在配置路由前，如果你是用docker启动的，先ip route show看一下，要是有什么default via 什么什么之类的，**第一步先删了它！**不然你的流量就会通过这个跑到物理机上头然后nat跑出去，简直白给。

启动vtysh命令外壳：
```bash
vtysh
```
首先，我们为Zebra配置日志文件。为此，输入下列内容，进入vtysh中的全局配置模式：
```bash
site-A-RTR# configure terminal
```
并指定日志文件位置，然后退出该模式：
```bash
site-A-RTR(config)# log file /var/log/quagga/quagga.log
site-A-RTR(config)# exit
```
永久性保存配置：
```bash
site-A-RTR# write
```
下一步，我们在必要时确定可用接口，然后配置IP地址。
```bash
site-A-RTR# show interface
```
```bash
Interface eth0 is up, line protocol detection is disabled
. . . . .
Interface eth1 is up, line protocol detection is disabled
. . . . .
```
这里哪个eth配那个也不一定，要根据互相ping出来的确定是哪一个
配置eth0参数：
```bash
site-A-RTR# configure terminal
site-A-RTR(config)# interface eth0
site-A-RTR(config-if)# ip address 10.10.10.1/30
site-A-RTR(config-if)# description to-site-B
site-A-RTR(config-if)# no shutdown
```
继续配置eth1参数：
```bash
site-A-RTR(config)# interface eth1
site-A-RTR(config-if)# ip address 192.168.1.1/24
site-A-RTR(config-if)# description to-site-A-LAN
site-A-RTR(config-if)# no shutdown
```
现在验证配置：
```bash
site-A-RTR(config-if)# do show interface
```
```bash
Interface eth0 is up, line protocol detection is disabled
. . . . .
inet 10.10.10.1/30 broadcast 10.10.10.3
. . . . .
Interface eth1 is up, line protocol detection is disabled
. . . . .
inet 192.168.1.1/24 broadcast 192.168.1.255
. . . . .
```
```bash
site-A-RTR(config-if)# do show interface description
```
```bash
Interface Status Protocol Description
eth0 up unknown to-site-B
eth1 up unknown to-site-A-LAN
```
永久性保存配置：
```bash
site-A-RTR(config-if)# do write
```
针对site-B服务器，也重复IP地址配置这个步骤。

要是一切顺利，你应该能够从site-A服务器来ping检测site-B的对等IP 10.10.10.2。

请注意：一旦Zebra后台程序已启动，用vtysh的命令行接口进行的任何更改会立即生效。不需要在配置变更后重启Zebra后台程序。

## 第2个阶段：配置OSPF

我们先创建一个OSPF配置文件，然后启动OSPF后台程序：
```bash
cp /usr/share/doc/quagga/examples/ospfd.conf.sample /etc/quagga/ospfd.conf

/usr/lib/quagga/ospfd -d
```
现在启动vtysh外壳，继续进行OSPF配置：
```bash
vtysh
```
进入路由器配置模式：
```bash
site-A-RTR# configure terminal
site-A-RTR(config)# router ospf
```
手动设置router-id：
```bash
site-A-RTR(config-router)# router-id 10.10.10.1
```
添加将参与OSPF的网络：

注意这里的网段，如果不是8/16/24,就要手动考虑一下是不是要更改倒数第二位/第三位之类的了
```bash
site-A-RTR(config-router)# network 10.10.10.0/30 area 0
site-A-RTR(config-router)# network 192.168.1.0/24 area 0
```
永久性保存配置：
```bash
site-A-RTR(config-router)# do write
```
针对site-B，也重复类似的OSPF配置：
```bash
site-B-RTR(config-router)# network 10.10.10.0/30 area 0
site-B-RTR(config-router)# network 172.16.1.0/24 area 0
site-B-RTR(config-router)# do write
```
OSPF邻居现在应该会出现。只要ospfd在运行，通过vtysh外壳所作的任何与OSPF有关的配置变更都会立即生效，没必要重启ospfd。

在下一个部分，我们将验证已安装的Quagga环境。

## 验证

1. 用ping来测试

首先，你应该能够从site-A来ping检测site-B的局域网了网。确保你的防火墙没有阻止ping检测流量。
```bash
[root@site-A-RTR ~]# ping 172.16.1.1 -c 2
```
2. 检查路由表

内核和Quagga路由表里面应该都有必要的路由。
```bash
[root@site-A-RTR ~]# ip route
10.10.10.0/30 dev eth0 proto kernel scope link src 10.10.10.1
172.16.1.0/30 via 10.10.10.2 dev eth0 proto zebra metric 20
192.168.1.0/24 dev eth1 proto kernel scope link src 192.168.1.1
```
```bash
[root@site-A-RTR ~]# vtysh
site-A-RTR# show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,
I - ISIS, B - BGP, > - selected route, * - FIB route
O 10.10.10.0/30 [110/10] is directly connected, eth0, 00:14:29
C>* 10.10.10.0/30 is directly connected, eth0
C>* 127.0.0.0/8 is directly connected, lo
O>* 172.16.1.0/30 [110/20] via 10.10.10.2, eth0, 00:14:14
C>* 192.168.1.0/24 is directly connected, eth1
```
3．验证OSPF邻居和路由器

在vtysh外壳里面，你可以检查必要的邻居有没有出现，是否记住合适的路由。
```bash
[root@site-A-RTR ~]# vtysh
site-A-RTR# show ip ospf neighbor
```
