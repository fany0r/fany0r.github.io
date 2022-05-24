---
title: 关于CS在Windows7无法上线问题
index_img: >-
  https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
banner_img: >-
  https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
copyright: true
abbrlink: 3bfe19c3
date: 2022-04-17 10:56:28
tags:
---

复现漏洞时，CS 使用Listener为https时，在win 7上无法上线，以为是证书问题，重复换了证书还是不行，但在win 10上则正常。

### 0x01 问题表现

主要表现为：

1、生成Windows分阶段Payload，打开exe会提示”xxx程序已停止“

![](https://s1.ax1x.com/2022/04/17/LNUTfO.png)

2、Windows无阶段Payload，打开就只是打开了，没任何反应也无法上线。

### 0x02 问题分析

wireshark 监控看看，走的是 TLSv1.2？

![](https://s1.ax1x.com/2022/04/17/LNUb1e.png)

从微软官方文档得知默认情况下windows 7并不支持，需要修改注册表手动开启支持 TLS 1.1和1.2...... 

但实战中不可能这么操作的。

https://support.microsoft.com/zh-cn/topic/%E6%9B%B4%E6%96%B0%E4%BA%86-%E4%BB%A5%E5%9C%A8-windows-%E4%B8%AD%E7%9A%84-winhttp-%E4%B8%AD%E5%90%AF%E7%94%A8-tls-1-1-%E5%92%8C-tls-1-2-%E4%BD%9C%E4%B8%BA%E9%BB%98%E8%AE%A4%E5%AE%89%E5%85%A8%E5%8D%8F%E8%AE%AE-c4bd73d2-31d7-761e-0178-11268bb10392

![](https://s1.ax1x.com/2022/04/17/LNUHpD.png)

其实，使用哪种通信协议版本是由服务端（CS）决定的，CS是用java运行的，那是否可以通过修改java默认TLS协议版本从而解决问题呢？

答案是，可以的。详细见 jdk文档 https://java.com/en/configure_crypto.html 

### 0x03 解决方法

编辑文件 java.security  搜索 `jdk.tls.disabledAlgorithms` 

Windows 为：

```basic
jdk1.8.xxx\jre\lib\security\java.security
jre1.8.0_xxx\lib\security\java.security
#jdk 11+
jdk-11.xxx\conf\security\java.security
```

Linux 为 ：`/etc/java-11-openjdk/security/java.security`

`C:\Program Files\Java\jdk-11.0.13\conf\security\java.security`

![](https://s1.ax1x.com/2022/04/17/LNUotK.png)

把 `SSLv3, TLSv1, TLSv1.1` ,删除，重新运行CS服务端即可。

