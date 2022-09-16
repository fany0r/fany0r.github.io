---
title: XMind 2021大客户版
tags: Xmind
categories:
  - 资源分享
copyright: true
abbrlink: 4fc730d4
index_img: https://assets.xmind.net/www/assets/images/download/new/img-download-zen@3x-7f572fc69b.png
banner_img: https://assets.xmind.net/www/assets/images/download/new/img-download-zen@3x-7f572fc69b.png
date: 2021-10-17 20:04:20
---

当前最新版：v11.1.0-202109232239

官方原版安装包下载地址： https://dl2.xmind.cn/XMind-for-Windows-64bit-11.1.0-202109232239.exe

官方安装包备份地址：https://wws.lanzoui.com/iWqwUv716kf 密码:c9ri

免安装版：https://wws.lanzoui.com/iOQ7Zv7165a 密码:3d80

**原版安装**

双击安装包，默认自动安装在：`C:\Program Files\XMind`，并且会自动启动该软件，先关闭软件。

![](https://z3.ax1x.com/2021/10/17/5tgY5t.png)

下载【app.asar】 https://wws.lanzoui.com/ikPtev6y8ba 密码:1mo5

解压替换 `C:\Program Files\XMind\resources\app.asar`。

下面两方法择其一：

方法一、新建系统变量VANA_LICENSE_TO，VANA_LICENSE_MODE，直接打开XMind。

![](https://z3.ax1x.com/2021/10/17/5tgJUI.png)

方法二、新建 如下文件两个文件保存到XMind安装目录下 `C:\Program Files\XMind\`

`XmindFull.cmd`

VANA_LICENSE_TO 值可自定义，也就是授权给谁。

```basic
@echo off
set VANA_LICENSE_TO="Xmind Sec666"
set VANA_LICENSE_MODE=true
start "" "%~dp0\XMind.exe" "%1"
```

`XMind.vbs`

```basic
CreateObject("WScript.Shell").Run """C:\Program Files\XMind\XmindFull.cmd""",0
```

双击[XMind.vbs]正常启动XMind。如提示输入激活码，选择跳过即可。

![](https://z3.ax1x.com/2021/10/17/5tgNPP.png)

创建快捷方式，XMind.vbs放到桌面，修改图标。

![](https://z3.ax1x.com/2021/10/17/5tgU8f.png)

经测试，所有导出功能均正常(前提是打印服务处于运行状态，非运行状态使用导出功能XMind会卡死无反应)。

**Tips**

1、关闭自动更新：编辑-首选项-关闭自动更新

2、~~通过Windows自带的防火墙(WF.msc)和火绒新建策略禁止XMind联网，原因嘛，懂的都懂，毕竟是破解难免有点啥。~~

Reference

https://www.bicfic.com/xmind-2021-crack-torrent-n/
