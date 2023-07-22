---
title: PC端微信小程序抓包
date: 2023-07-22 22:49:12
copyright: true
tags:
index_img: https://s1.ax1x.com/2023/07/22/pCqd37T.png
banner_img: https://s1.ax1x.com/2023/07/22/pCqd37T.png
---


### 环境

Windows 10 x64

BurpSuite v2023.4.5(需提前安装好证书)

微信 v3.9.5.91

Clash for Windows v0.20.29

https://github.com/Fndroid/clash_for_windows_pkg/releases

### 配置 Clash for Windows

`General` -> `Service Mode Manage` -> `winsw` -> `Install`

安装 `Service Mode`  

![](https://s1.ax1x.com/2023/07/22/pCqd1BV.png)

软件会重新启动，Service Mode 旁边的小地球变成绿色则代表成功安装Service Mode。

新建一个 `.yaml` 文件，写入如下内容：

```yaml
port: 7890                 # HTTP代理端口
socks-port: 7891           # SOCKS5代理端口
allow-lan: false           # 禁止局域网共享
mode: Rule                 # 代理模式（Global, Rule, Direct）
log-level: info            # 日志记录级别（silent, info, warning, error, debug）
external-controller: :9090 # Clash外部控制器的地址和端口

proxies: 
  - name: burpsuite        # 代理名为'burpsuite'
    type: http             # 代理类型
    server: 127.0.0.1      # Burp Suite地址
    port: 8080             # Burp Suite端口

proxy-groups:              # 代理组
  - name: ✨转发至         # 代理组名
    proxies:               # 包含在此组中的代理
      - burpsuite          # 包括上面定义的'burpsuite'代理
    type: select           # 代理组类型设置为select

rules:                     # 代理规则
  # 过滤微信垃圾数据，防止干扰
  - DOMAIN,szminorshort.weixin.qq.com,DIRECT 
  - DOMAIN,long.open.weixin.qq.com,DIRECT
  - DOMAIN,res.wx.qq.com,DIRECT
  - DOMAIN-SUFFIX,qpic.cn,DIRECT
  - DOMAIN-SUFFIX,qlogo.cn,DIRECT
  - DOMAIN-SUFFIX,gtimg.cn,DIRECT
  - DOMAIN-SUFFIX,cdntips.net,DIRECT
  - DOMAIN-SUFFIX,weixinbridge.com,DIRECT
  - IP-CIDR,183.47.0.0/16,DIRECT
  # 按进程过滤-直连
  - PROCESS-NAME,java.exe,DIRECT
  - PROCESS-NAME,BurpSuitePro.exe,DIRECT
  # 凡是小程序'主进程WeChatAppEx.exe'发起的请求全转至'burpsuite'
  - PROCESS-NAME,WeChatAppEx.exe,burpsuite
  - MATCH,DIRECT                             # 默认全部直连

```

如有需要，以上rules按需修改。

### 导入配置文件到 clash

把yaml文件导入clash并启用它：`Profiles` -> `Import`

![](https://s1.ax1x.com/2023/07/22/pCqdln0.png)

### 开启 TUN Mode 

在clash for windows主页面或者右键通知栏clash图标开启 `System Proxy `和 `TUN Mode` 。

![](https://s1.ax1x.com/2023/07/22/pCqdMXq.png)

打开burpsuite开始基操。

![](https://s1.ax1x.com/2023/07/22/pCqdGAU.png)

Reference

https://chat.openai.com
https://www.google.com
