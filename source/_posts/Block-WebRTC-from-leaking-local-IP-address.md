---
title: Block WebRTC from leaking local IPaddress
index_img: >-
  https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
banner_img: >-
  https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
copyright: true
abbrlink: ee0c8274
date: 2022-09-08 19:16:33
tags:
---


​	WebRTC 是一项实时通讯技术，它允许网络应用或者站点，在不借助中间媒介的情况下，建立浏览器之间点对点的连接，实现视频流和（或）音频流或者其他任意数据的传输。WebRTC 包含的这些标准使用户在无需安装任何插件或者第三方的软件的情况下，创建点对点的数据分享和电话会议成为可能。

​	简而言之这玩意主要是支持网络视频/会议等飞速流畅不卡顿的，但同时也会暴露所处本地内网IP、代理后面的真实IP。挂`VPN`不影响(前提是该VPN可靠)，获取回到IP也只是VPN服务商那边的IP。iPhone（IOS15.5+）不受影响。

测试站点：

https://www.useragentinfo.com/

https://www.hackjie.com/tracking

https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

### 0x01 基于浏览器扩展/脚本

#### 插件

Firefox 

https://addons.mozilla.org/zh-CN/firefox/addon/happy-bonobo-disable-webrtc/

https://addons.mozilla.org/zh-CN/firefox/addon/webrtc-leak-shield/

Chrome系(不适用移动端)

https://chrome.google.com/webstore/detail/webrtc-leak-shield/bppamachkoflopbagkdoflbgfjflfnfl?hl=zh-CN

https://microsoftedge.microsoft.com/addons/detail/webrtc-leak-shield/pblfgfehcokbglafpcldgjpmknildihk?hl=zh-CN

https://chrome.google.com/webstore/detail/webrtc-leak-prevent/eiadekoaikejlgdbkbdfeijglgfdalml?hl=zh-CN

#### 油猴(Tampermonkey)脚本

如下脚本适用PC端和手机端（via/Alook浏览器），即支持运行自定义js脚本的浏览器皆适用。

```javascript
// ==UserScript==
// @name         Disable WebRTC
// @namespace    http://tampermonkey.net/
// @version      0.2
// @description  Disable WebRTC for all web site
// @author       Sec
// @match        http://*
// @match        https://*/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @grant        none
// @run-at		 document-start
// ==/UserScript==

(function() {
    'use strict';

    delete navigator.getUserMedia;
    delete navigator.mediaDevices.getUserMedia;
    delete navigator.mozGetUserMedia;
    delete navigator.webkitGetUserMedia;
    delete window.MediaStreamTrack;
    delete window.RTCPeerConnection;
    delete window.RTCSessionDescription;
    //
    delete window.mozMediaStreamTrack;
    delete window.mozRTCPeerConnection;
    delete window.mozRTCSessionDescription;
    //
    delete window.webkitMediaStreamTrack;
    delete window.webkitRTCPeerConnection;
    delete window.webkitRTCSessionDescription;
    //
    delete window.RTCDataChannel;
    delete window.DataChannel;

    console.log("Accelerator killed WebRTC.");
})();
```

### 0x02 基于浏览器配置

chrome系已经移除了通过高级配置WebRTC相关功能，目前只通过浏览器插件或者油猴脚本实现。

Firefox可做如下设置：进入高级配置界面 `about:config`，搜 `media.peerconnection.enabled`，改为`false`。

### 0x03 基于防火墙

WebRTC默认走UDP，针对浏览器，新建策略禁止UDP协议连接。





