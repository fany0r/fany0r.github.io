---
title: PC端微信小程序抓包
copyright: true
index_img: 'https://s1.ax1x.com/2023/07/22/pCqd37T.png'
banner_img: 'https://s1.ax1x.com/2023/07/22/pCqd37T.png'
abbrlink: 909b5a7d
date: 2023-07-22 22:49:12
tags:
---


### 0x01 环境

Windows 10 x64（需提前安装好BP证书至`受信任的根证书颁发机构`中）

BurpSuite v2023.4.5

微信 v3.9.5.91

Clash for Windows v0.20.29

https://github.com/Fndroid/clash_for_windows_pkg/releases

### 0x02 配置 Clash for Windows

`General` -> `Service Mode Manage` -> `winsw` -> `Install`

安装 `Service Mode`  

![](https://s1.ax1x.com/2023/07/22/pCqd1BV.png)

软件会重新启动，Service Mode 旁边的小地球变成绿色则代表成功安装Service Mode。

新建一个 `BP.yaml` 文件，写入如下内容：

```yaml
port: 7890
socks-port: 7891
allow-lan: false
mode: Rule                 # 代理模式（Global, Rule, Direct）
log-level: info            # 日志记录级别（silent, info, warning, error, debug）
external-controller: :9090 # Clash外部控制器的地址和端口

proxies: 
  - name: burpsuite        # 代理名为 burpsuite
    type: http             # 代理类型
    server: 127.0.0.1      # Burp Suite地址
    port: 8080             # Burp Suite端口

proxy-groups:              # 代理组
  - name: ✨转发至         # 组名
    proxies:
      - burpsuite
    type: select

rules:
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
  ##
  # 过滤BP相关的进程-直连
  - PROCESS-NAME,java.exe,DIRECT
  - PROCESS-NAME,BurpSuitePro.exe,DIRECT
  ##
  # 把小程序主进程发起的请求转至BP
  - PROCESS-NAME,WeChatAppEx.exe,burpsuite
  - PROCESS-NAME,WechatBrowser.exe,burpsuite
  ##
  # 默认全部直连
  - MATCH,DIRECT

```

如有使用其他代理工具，按需修改以上rules。

详细见：

https://docs.cfw.lbyczf.com/contents/ui/profiles/rules.html

https://www.codein.icu/clashtutorial/#%E7%BC%96%E8%BE%91%E8%A7%84%E5%88%99


### 0x03 导入配置文件到 clash

把yaml文件导入 clash 并启用它：`Profiles` -> `Import`

![](https://s1.ax1x.com/2023/07/22/pCqdln0.png)

### 0x04 开启 TUN Mode 

在 Clash for Windows 主界面或者右键通知栏clash图标开启 `System Proxy `和 `TUN Mode` 。

![](https://s1.ax1x.com/2023/07/22/pCqdMXq.png)

注：成功开启 `TUN Mode` 的标志为Windows右下角网络会多出一个网卡连接。

微信不需要任何设置，打开burpsuite开始基操即可。

![](https://s1.ax1x.com/2023/07/22/pCqdGAU.png)

注：如果抓到包有很多 mmtls 请求或只显示ip地址和端口不显示域名，又或者无法转抓包时，可以尝试删除小程序文件夹/多次重启Clash等操作。

Reference

https://chat.openai.com
https://www.google.com
