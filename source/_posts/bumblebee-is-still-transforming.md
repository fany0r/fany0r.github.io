---
title: BumbleBee-此大黄蜂非擎天柱的里大黄蜂但它仍然在变形
date: 2022-08-20 21:10:44
tags:
categories:
  - 转载搬运
index_img: https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
banner_img: https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
---

此大黄蜂非擎天柱的里大黄蜂但它仍然在变形

原文：https://www.proofpoint.com/us/blog/threat-insight/bumblebee-is-still-transforming

## 主要重点

- Proofpoint 监测到了一个名为 BumbleBee 的新恶意软件加载程序，该加载器由多个犯罪威胁组织在使用，观察到以往这些犯罪威胁者提供基本加载器(BazaLoader)和IcedID。
- 一些常用BazaLoader的威胁攻击者已经过度到 BumbleBee 。从2022年2月开始，BazaLoader 尚未出现在Proofpoint数据中。
- BumbleBee 处于维护中，并使用复杂的规避技术，如反虚拟化。
- 与大多数使用进程空心化或DLL注入的其他如意软件不同，此加载器利用了异步过程调用（APC）注入从命令和控件（C2）接收的命令启动shellcode。
- Proofpoint观察到Bumblebee掉落Cobalt Strike，shellcode，Slimver和Meterpreter。
- 使用Bumblebee的威胁行为者与与后续勒索软件活动相关的恶意软件有效payload相关。

## 概述

​	从2022年3月开始，Proofpoint监测到了一个名为Bumblebee的新下载器的活动。包括已知的威胁行为者在内的至少三个活动集群目前正在使用BumbleBee。Proofpoint 识别的活动与 Google 威胁分析组博客中详述的导致 Conti 和 Diavol 勒索软件的活动重叠。

​	BumbleBee 是一个复杂的下载器，包含反虚拟化检测和通用下载器功能，尽管它目前还处于恶意软件开发的早期阶段。

​	Bumblebee 的目标是下载和执行额外的有效载荷。  Proofpoint 研究人员观察到 Bumblebee 丢弃了 Cobalt Strike、shellcode、Sliver 和 Meterpreter。恶意软件名称来自早期活动中使用的唯一User-Agent“bumblebee”。

​	BumbleBee 在威胁领域的增加与 BazaLoader  相吻合，BazaLoader  是一种常用的payloads加载器，可促进后续攻击，但在好像消失了--来自 Proofpoint 威胁数据。

## 威胁详情

​	Proofpoint 研究人员监测到 Bumblebee 被至少三个跟踪的威胁参与者分发到电子邮件活动中。 威胁攻击者使用多种技术来传播 Bumblebee。  虽然使用的诱饵、传递技术和文件名通常是针对分发活动的不同威胁攻击者组织定制的，但 Proofpoint 观察到活动之间的几个共同点，例如使用包含快捷方式文件和 DLL 的 ISO 文件以及多个参与者使用的通用 DLL 入口点。

### 指向BumbleBee的URL和HTML文件

​	2022年3月，Proofpoint 监测到一个附带有 DocuSign 品牌的钓鱼邮件，邮件内含两个链接，用于诱导收件人下载恶意ISO文件。一个是在邮件正文中的“查看此文档”超链接。当用户点击后，会跳转到托管在 OneDrive的是压缩文件（ISO）。

![](https://s1.ax1x.com/2022/08/20/vsLgIg.png)

另外一个是，邮件中还包含一个HTML附件，该HTML文件伪装成一个指向未支付订单的电子邮件。HTML附件中嵌入了可重定向的URL，它使用Prometheus TDS根据潜在受害者的时区和cookie过滤下载。重定向器反过来将用户定向到压缩文件，该文件也托管在OneDrive上。

![](https://s1.ax1x.com/2022/08/20/vsLcdS.png)

压缩文件内包含一个名为 `Invoice-32203.iso` 的ISO文件。

![](https://s1.ax1x.com/2022/08/20/vsL6Z8.png)

ISO文件内包含名为 `Attachments.lnk`  快捷方式和 `Attachments.dat` 文件。

![](https://s1.ax1x.com/2022/08/20/vsLRiQ.png)

如果双击打开 Attachments.lnk 会执行 Attachments.dat (实际上是一个dll文件)，从而运行下载器 BumbleBee。


快捷方式 Attachments.lnk  的命令及进程攻击链：

```bash
cmd.exe /c start /wait "" "C:\Users\[removed]\AppData\Local\Temp\ATTACHME.LNK"
rundll32.exe "C:\Windows\System32\rundll32.exe" Attachments.dat,IternalJob
```

![](https://s1.ax1x.com/2022/08/20/vsLWGj.png)

​	Proofpoint 研究人员确认这次攻击活动是有网络犯罪组织 TA579发起的。从2021年8月以来，Proofpoint一直在跟踪 TA579。该威胁行为者在过去的活动中经常提供 BazaLoader 和 IcedID。

### 压缩的ISO附件包含BumbleBee导致进程被劫持

​	2022年4月，Proofpoint监测到一个进程劫持攻击活动，该活动发送的电子邮件似乎是对带有恶意压缩ISO文件的现有安全电子邮件对话的回复。此活动中的所有附件名称都使用了`doc_invoice_[数字].zip`的形式进行命名。

![](https://s1.ax1x.com/2022/08/20/vsLfRs.png)

ISO文件位于带密码ZIP中，解压密码则已经写在邮件正文中。ISO含有两个文件，一个快捷方式和dll。当受害者双击打开快捷方式文件`DCOUNENT.LNK`时，会变相的通过cmd调用rundll32执行dll文件 `tar.dll` 从而启动BumbleBee下载器。

快捷方式 进程链：

![](https://s1.ax1x.com/2022/08/20/vsL5Mq.png)

BumbleBee 攻击链：

![](https://s1.ax1x.com/2022/08/20/vsLhzn.png)

### 联系表单"Stolen Images"指向BumbleBee

2022年3月，Proofpoint 监测到一项活动，该活动通过向目标网站上的联系表格提交消息而生成电子邮件。 此外，根据网站“联系我们”部分的配置方式，提交的内容还在目标网站上留下了关于该主题的公众评论。 这些电子邮件据称声称网站上存在被盗图像。

![](https://s1.ax1x.com/2022/08/20/vsLLi4.png)

"投诉"表单包含了一个指向登录页面的超链接，点击该超链接会打开一个下载ISO文件的页面，该ISO文件内包含一个lnk(`DOCUMENT_STOLENIMAGES.LNK`)和dll(`neqe.dll`)文件。

![登录页面样式](https://s1.ax1x.com/2022/08/20/vsLIs0.png)

如果双击打开快捷方式文件，就会通过相应的参数执行`neqw.dll`从而启动 BumbleBee 加载器。

![指向BumbleBee的表单攻击链](https://s1.ax1x.com/2022/08/20/vsLoLV.png)

Proofpoint 将此活动归因于 TA578，这是 Proofpoint 研究人员自 2020 年 5 月以来一直在跟踪的威胁行为者。TA578 此前曾在基于电子邮件的活动中监测到，这些活动提供 Ursnif、IcedID、KPOT Stealer、Buer Loader、BazaLoader 和 Cobalt Strike。

## 与其他恶意软件的关系

​	多个威胁参与者正在使用BumbleBee，将其引入环境的时间及本报告中描述的行为可以被认为是网络犯罪威胁领域的转折点。此外，Proofpoint以适度的信心评估使用BumbleBee的攻击者可能被视为初始访问促进，即，渗透主要目标然后向后续勒索软件行为者出售访问权的独立网络犯罪组织。

​	至少三个被跟踪的通常传播 BazaLoader 恶意软件的威胁行为者已经过渡到 Bumblebee 有效载荷，BazaLoader 最后一次出现在 Proofpoint 数据中是在 2022 年 2 月。

​	BazaLoader 是 2020 年首次发现的第一阶段下载器，与包括 [Conti](https://thedfirreport.com/2021/10/04/bazarloader-and-the-conti-leaks/) 在内的后续勒索软件活动有关。  Proofpoint 研究人员最初监测到 BazaLoader 由主要有传播 Trick 银行木马的威胁行为者大量传播。

![BazaLoader 和 Bumblebee 精选活动的时间表](https://www.proofpoint.com/sites/default/files/inline-images/image-20220428121656-1.png)

​	BazaLoader 从网络犯罪威胁领域的明显消失恰逢 Conti Leaks 发生的时间，2022 年 2 月末，一名有权访问 Conti 内部操作的乌克兰研究人员开始从网络犯罪组织泄露数据。  在泄露的文件中发现了与 BazaLoader 相关的基础设施。

## 恶意软件分析

BumbleBee 是一款用C++写的下载器。分析的初始BumBleBee DLL样本包含两个导出，一个是直接启动 Bumblebee 主函数的线程，另一个最终导致相同的主函数，但添加了检查钩子是否已放置在关键动态链接库 (DLL) 中，加载此 DLL 的 LNK 会跳过默认的 DllMain 函数，而是调用检查函数挂钩的导出。

![BumBleBee hook检查](https://s1.ax1x.com/2022/08/20/vsLHdU.png)

和大多数恶意软件不同，BumBleBee加载器的大部分内容都被压缩为一个方法函数，后面的初始化、请求发送和响应处理都被分解为不同的函数。该加载器首先复制有效作用僵尸网络标识符的GroupID，于大多数恶意软件不同，BumBleBee 目前以明文形式存储其配置，但在未来可能会增加混淆功能。复制GroupID后，加载器会解析各种NTDLL函数的地址，使其能够加载过程之后能正常执行注入。

![复制和设置GroupID](https://s1.ax1x.com/2022/08/20/vsL7ZT.png)

一旦解析函数，就会创建一个独特的事件，该事件作用互斥以确保只有一个加载器示例正在运行。

![创建事件](https://s1.ax1x.com/2022/08/20/vsLboF.png)

此时，确认单个 Bumblebee 实例正在运行，恶意软件开始收集系统信息。  以下 WMI 查询通过 COM 对象执行以收集通信所需的详细信息：

- SELECT * FROM Win32_ComputerSystem
- SELECT * FROM Win32_ComputerSystemProduct

根据查询输出收集和连接系统的主机名和UUID，然后生成此值的MD5哈希并将其转换为十六进制的结果作为机器的唯一客户端ID。

![创建客户端ID](https://s1.ax1x.com/2022/08/20/vsLOJJ.png)

生成客户端ID后，加载器创建系统版本字符串，其中包括WMI查询的标题、主机的用户名和主机的域。

收集到所有这些信息后，加载器开始与 C2 通信，加载器每 25 秒检查一次 C2 以接收命令。和大多数具有立即返回给客户端的模块或有效负载的恶意软件不同，该恶意软件背后的攻击者似乎手动将有效负载部署到Bumblebee，因为它可能需要几个小时才能收到任何要执行的作业。每个服务器响应都包含下图中显示的数据的变体。如果返回有效任务，“tasks”值将是包含所有任务信息的字典列表。

![*Bumblebee 响应内容](https://s1.ax1x.com/2022/08/20/vsLXW9.png)

*Bumblebee* 加载器支持以下命令：

```sqlite
Shi：shellcode 注入
Dij：DLL注入
Dex：下载执行文件
Sdl：卸载加载器
Ins：在目标上开启权限维持
```

### Ins 命令

Ins 命令通过将 Bumblebee DLL 复制到 `%APPDATA%` 文件夹的子目录并创建将加载 DLL 的 VBS 脚本来启用权限维持，然后创建计划任务，通过 wscript.exe 调用 VBS 脚本。

![通过VBS加载DLL](https://s1.ax1x.com/2022/08/20/vsLjzR.png)

![使用VBS创建计划任务](https://s1.ax1x.com/2022/08/20/vsLxQ1.png)

### Dex 命令

Dex 命令是支持的命令中最基本命令，该命令从服务器响应中获取 base64 解码的内容，以硬编码路径将其写入磁盘并通过 COM 对象执行。

![Dex命令输出](https://www.proofpoint.com/sites/default/files/inline-images/image-20220427171513-20.png)

### Dij 命令

Dij 命令增加了将 DLL 注入其他进程内存的能力，对于注入目标，恶意软件会选择三个硬编码选项之一来将 DLL 注入到ImagingDevices.exe、wab.exe 或 wabmig.exe。

![将可执行文件识别为注入目标](https://s1.ax1x.com/2022/08/20/vsLzsx.png)

选择一个随机可执行文件后，加载器会以挂起状态启动进程，使得恶意软件可以轻松操作该过程而不被发现。接下来，它通过启用调试权限来准备进程注入，以便注入执行所需的shellcode。

![创建新进程和启用调试权限](https://s1.ax1x.com/2022/08/20/vsOSL6.png)

设置适当的权限后，可以操作数据，加载器将shellcode写入挂起的进程，用新的入口点覆盖初始入口点，这个入口点实现写入32字节的shellcode，并将占位符替换为SleepEx的解析地址功能。

![SleepEx替换占位符数值](https://s1.ax1x.com/2022/08/20/vsO9eK.png)

如下图所示，shellcode 程序集中的 `call RAX` 指令被替换为 SleepEx 的地址，延迟1000毫秒，shellcode 调用 SleepEx ，然后将 shellcode 注入到进程中，进程恢复。

![反汇编后的shellcode](https://s1.ax1x.com/2022/08/20/vsOCdO.png)

加载器通过 APC 例程将恶意负载注入到可执行文件中。

![通过APCj进行进程注入](https://s1.ax1x.com/2022/08/20/vsOPoD.png)

为了成功并正确的注入，加载器在注入目标中创建两个新部分，并将缓冲区从 dij 复制到新的内存空间，然后通过动态解析的 `NtQueueApcThread` 调用目标可执行文件中复制的内容。

![创建两个内存空间](https://s1.ax1x.com/2022/08/20/vsOFFe.png)

![调用动态解析的 NtQueueApcThread](https://s1.ax1x.com/2022/08/20/vsOkJH.png)

### 恶意软件开发

Proofpoint 研究人员监测到，在一月份的活动中，BumbleBee 开发人员为恶意软件添加了新功能，具体来说，包括反虚拟机和反沙盒检查。以下是较早的示例：

![旧版BumBleBee样本](https://s1.ax1x.com/2022/08/20/vsOAWd.png)

最新样本，更新了 BumbleBee 示例，添加了 check_bad_artifacts。

![最新BumBleBee样本](https://s1.ax1x.com/2022/08/20/vsOVSA.png)

通过研究新功能，我们发现了一个新的方法：

![反编译恶意软件的框架检查](https://s1.ax1x.com/2022/08/20/vsOZQI.png)

下图是 Al Khaser 工具的一部分，该工具是用于检查 VM 工件的常用工具，Bumblebee 加载器的开发人员似乎依赖开源工具，就像标准开发人员一样。

![来自 Al Khaser 的开源代码显示完全相同的检查](https://s1.ax1x.com/2022/08/20/vsOmOP.png)

## 重大更新

Proofpoint 表示，在2022年4月19 日观察到的最新版本 BumbleBee 中，BumbleBee 功能发生了重大变化，现在支持通过逗号分隔列表支持多个 C2。

![多个嵌入式C2](https://s1.ax1x.com/2022/08/20/vsOeyt.png)

旧版中硬编码设置了睡眠时间 25秒，在新版本中已经改为了随机。

![随机sleep](https://s1.ax1x.com/2022/08/20/vsOuef.png)

该恶意软件最明显的变化是在网络通信中增加了一个加密层，开发人员通过RC4硬编码密钥添加到样本中，用于加密请求和解密响应。

![加密请求内容](https://www.proofpoint.com/sites/default/files/inline-images/image-20220427171513-34.png)

![解密响应内容](https://www.proofpoint.com/sites/default/files/inline-images/image-20220427171513-35.png)

作为该组织的另一个标志，展示了他们快速的开发速度，4月22日，Proofpoint 监测到该组织向 BumbleBee 添加了一个新线程，该线程根据恶意软件分析师使用的常用工具的硬编码列表来检查当前正在运行的进程，该线程在 BumbleBee 进程开始时创建。

![Bumblebee 主函数显示新线程的开始](https://www.proofpoint.com/sites/default/files/inline-images/image-20220427171513-36.png)

如果找到这些进程中的任何一个，该函数将返回 1，这会触发 BumbleBee 主线程终止。

![BumBleBee检查工具列表](https://www.proofpoint.com/sites/default/files/inline-images/image-20220427171513-37.png)

## 结论

Bumblebee 是一个复杂的恶意软件加载程序，它展示了持续开发的证据， 它被多个网络犯罪威胁攻击者使用。  Proofpoint 高度自信地评估 BumbleBee 加载器可用作初始访问促进者，以提供后续有效负载，例如勒索软件。  根据它在威胁环境中出现的时间以及被多个网络犯罪团伙使用的时间，BumbleBee 很可能是BazaLoader 的直接替代品，那么它是一种新的多功能工具，由历史上偏爱其他恶意软件的行为者使用。

### 通信样本

| 样本                                                             | 类型   | 描述                          |
| ---------------------------------------------------------------- | ------ | ----------------------------- |
| c6ef53740f2011825dd531fc65d6eba92f87d0ed1b30207a9694c0218c10d6e0 | SHA256 | 2022年3月31日至4月1日ISO 样本 |
| a72538ba00dc95190d6919756ffce74f0b3cf60db387c6c9281a0dc892ded802 | SHA256 | 2022年3月31日至4月1日样本     |
| 77f6cdf03ba70367c93ac194604175e2bd1239a29bc66da50b5754b7adbe8ae4 | SHA256 | 2022年4月5日ISO样本           |
| 0faa970001791cb0013416177cefebb25fbff543859bd81536a3096ee8e79127 | SHA256 | 2022年4月5日Bumblebee 样本    |
| Fe7a64dad14fe240aa026e57615fc3a22a7f5ba1dd55d675b1d2072f6262a1   | SHA256 | 2022年3月28日至4月1日ISO样本  |
| 08CD6983F183EF65EABD073C01F137A913282504E2502AC34A1BE3E599AC386B | SHA256 | 3月10日未混淆的Bumblebee 样本 |

