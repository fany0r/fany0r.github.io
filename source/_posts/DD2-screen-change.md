---
title: 记一次炫龙毁灭者DD2换屏&更新BIOS过程
categories:
  - 杂项
index_img: 'https://s1.ax1x.com/2022/09/04/vT3o4K.jpg'
banner_img: 'https://s1.ax1x.com/2022/09/04/vT3o4K.jpg'
copyright: true
abbrlink: 843d207e
date: 2022-08-18 22:51:56
tags:
---


### 0x01 背景

​	机器于18年在某东平台购买，用了四年的机子突然某天屏幕不亮，接外屏是正常的。用强光手电照屏幕发现是有图像，那八成是屏幕灯管老化损坏了，才导致的无背光现象。拿去单纯修背光的话，不值得。而且原来的屏幕 45%NTSC的色域，很low屏幕还泛黄，索性在某宝上买个好点的屏幕自己换上就好了。


屏幕规格：【京东方NY0  144Hz ，100SRGB色域，72NTSC，IPS A+屏，40的针屏线】，实际收到的确是165Hz的屏...

然后还存在两个“问题”，一是卖家配的40针屏线比原来的线短了一节，二是换上新屏后开机Logo页面和BIOS界面显示不全(需要更新BIOS)。

![新旧屏线](https://s1.ax1x.com/2022/09/04/vT3MnA.png)


### 0x02 拆机

​	主要注意的就是需要拆掉键盘后卸掉6个螺丝才能拆整个D面最终才可拆换屏线，换屏线前最好是把B壳拆掉旧屏幕拿出来，其他的没什么好说的，有手就行。可以参考：[小秋搞机炫龙毁灭者DD2 DC2 NB50TK1拆机视频](https://v.qq.com/x/page/v0702wv90md.html)

![拆开整个D壳后](https://s1.ax1x.com/2022/09/04/vT3Y9S.png)

### 0x03 换屏线

​	拆下旧屏线换上新的屏线，果然短了一截，按照原来的布局走线，由于线短了一节，就算把屏线拉直屏幕四个螺丝孔依然对不上，没法安装。

![屏线](https://s1.ax1x.com/2022/09/04/vT3uXd.png)

让卖家重新发一条屏线？时间久太麻烦了，按下图改一下路线就走可以了。

![屏线走线](https://s1.ax1x.com/2022/09/04/vT3NcQ.png)

按新布局走线后确实可以正常装上屏幕，也点亮开机了。但是 开机Logo页面和BIOS界面显示不全。

![偏离中心的开机logo](https://s1.ax1x.com/2022/09/04/vT3Q0I.png)


![BIOS界面显示不全](https://s1.ax1x.com/2022/09/04/vT3l7t.png)

后面爬了许多贴子才得知，大概率是笔记本当前的BIOS版本太低了，无法自适应调节高刷屏，升级BIOS即可。

### 0x04 更新BIOS和EC

​	属于蓝天模具的DD2并没有像主流主板厂商提供一键更新BIOS的软件或者是BIOS内更新选项，所以更新BIOS变成了一件略带危险而又有点复杂的事情，稍有不慎笔记本电脑就成砖了。



首先到 [Clevo mirror网站](https://repo.palkeo.com/clevo-mirror/NB5TK1_TJ1/) 下载适用DD2的 最新版BIOS和EC固件，用户名和密码都是 repo

下载后解压，先升级EC才能升级BIOS，升级操作前最好是进BIOS界面把安全启动关掉(security boot)。

![EC固件](https://s1.ax1x.com/2022/09/04/vT33AP.png)

升级EC需要用到 `ECWinFlash`，下载地址：https://wwp.lanzouy.com/b02dmqdqd 密码:1x0b 

打开ECWinFlash 会弹出出几个警告，确定下一步即可。

![ECWinFlash](https://s1.ax1x.com/2022/09/04/vT38tf.png)

软件左侧为是当前的EC版本信息。点击右上角三个点选择下载的新EC固件，然后点击左侧的Flash按钮，就会自动刷写，刷写过程中最好不要操作。右侧小窗口有进度信息，刷完后会自动关机。在关机后拔掉AC电源线并且把笔记本电池也拆掉，等待约15秒后重新装回电池插上电源开机，连续按F2，无意外的话进入BIOS界面，即可看到EC版本已经更新。

下一步更新BIOS，以管理员身份打开CMD，转到BIOS固件目录下，执行 `WMeset.exe`会自动重启电脑，用于解锁BIOS写入保护功能，同时风扇会最大转速旋转。

![解锁BIOS写入保护功能](https://s1.ax1x.com/2022/09/04/vT3Gh8.png)

重启后再次以管理员身份打开cmd 切换到BIOS固件目录下手动执行 `FPTW64.exe -f NB50TJ1.BIN -bios` 或者`FlashMEWinX64.bat` 开始刷入BIOS。其中可能会提示BIOS大小不一致，是否确定要刷入，根据提示输入确定即可。

![刷入BIOS](https://s1.ax1x.com/2022/09/04/vT3t1g.png)

刷写完BIOS手动关机，拔掉电源线，拆掉电池等待15秒左右，然后重新开机，会进入1分钟左右黑屏状态，待到屏幕上出现蓝色提示框（也有可能只是闪一下屏）说明已经完成了BIOS刷写，按两三下回车键电脑就会进入BIOS界面，重新把安全启动开启，保存并重启开机即可。



Reference

https://tieba.baidu.com/p/6048985832
https://v.qq.com/x/page/v0702wv90md.html
https://www.bilibili.com/read/cv6145892/
https://www.cnblog.com/feiquan/
https://www.cnblogs.com/feiquan/p/10225301.html
