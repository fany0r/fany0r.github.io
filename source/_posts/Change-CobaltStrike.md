---
title: 修改Cobalt Strikex小记
abbrlink: '324e2628'
date: 2022-04-15 1:51:37
tags:
copyright: true
index_img: https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
banner_img: https://rmt.ladydaily.com/fetch/fluid/storage/hexo-static/cover.jpg?w=480&fmt=webp
---


## CS 本身

修改特征：watermark水印、Stager Url算法(checksum8)、Beacon Config密钥。


### 0x01 反编译JAR包

1、用IEDA中的 java-decompiler.jar来进行反编译CS (需要JDK 11及以上)。
jar包位于：plugins\java-decompiler\lib
Windows 下，即：C:\Program Files\JetBrains\IntelliJ IDEA 2020.3.2\plugins\java-decompiler\lib

2、原版CS 4.4 jar
[https://www.ddosi.org/cobaltstrike-4-4-csagent/](https://www.ddosi.org/cobaltstrike-4-4-csagent/) 
[https://github.com/trewisscotch/CobaltStr4.4/](https://github.com/trewisscotch/CobaltStr4.4/)

目录结构：

```basic
D:\JAVAPROJECT\CS-CMPILATION
│  java-decompiler.jar
├─cs_bin # 原cs jar 目录
│      cobaltstrike.jar
└─cs_src # 反编译输出目录
```

运行反编译命令

```basic
java -cp java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dsg=true .\cs_bin\cobaltstrike.jar .\cs_src
```

反编译完成后得到cs的java源码， cs_src\cobaltstrike.jar 是个zip，解压即可导入IDEA。


### 0x02 环境搭建

主要参考：

https://pingmaoer.github.io/2020/06/24/CobaltStrike二次开发环境准备/


#### 新建 IDEA 项目

JDK选 1.8 ，选择低版本jdk是为了向上兼容。
然后新建俩文件夹，decompiled_src和lib，decompiled_src放反编译得到的源码，lib放原版cs jar包。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036219625-3f45166c-41da-4243-b959-f06ccda0f247.png" referrerPolicy="no-referrer" />



#### 设置项目结构

IDEA左上角 文件 > 项目结构 > 模块 > 依赖 添加原版 cobalt strike.jar

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036220147-59841a91-f4d9-4f14-95f4-62a99b3684d8.png" referrerPolicy="no-referrer" />

<br/> 打勾启用

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036220578-b8f9b0aa-a386-4abf-aeef-88bdda384f32.png" referrerPolicy="no-referrer" />

<br/> 设置入口 ，项目结构 > 工件 > JAR > 来自具有依赖项的模块...

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036221088-1342a390-8235-4dbb-8aa5-134d4610b601.png" referrerPolicy="no-referrer" />

<br/> Main-Class ：aggressor.Aggressor

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036221513-27dc9b4e-26ab-41bc-8e7b-4a6cfb484d0c.png" referrerPolicy="no-referrer" />

<br/> 测试：src下新建软件包：aggressor，然后转到反编译完的aggressor中Aggressor.java，按F5，或者右键 重构 > 复制文件 至 aggressor ，**后续修改其他模块代码也是如此操作**。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036221900-7827e08a-6103-426e-a7bd-56cc41c8fe7c.png" referrerPolicy="no-referrer" />

<br/> 编辑 Aggressor.java 添加弹窗测试代码如：`JOptionPane.showMessageDialog(null,"hello CS!!!");`

生成jar包，菜单，构建 > 构建工件，会在 out/artifacts/xx/ 下生成jar包。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036222300-a423bc4e-4166-486e-b7f7-6da149d75e09.png" referrerPolicy="no-referrer" />



#### 添加运行/调试配置

jar路径：上面生成的jar包。虚拟机选项写 [-XX:+AggressiveHeap -XX:+UseParallelGC]

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036222608-7a2431af-e1a1-4dad-84fa-696733282be6.png" referrerPolicy="no-referrer" />

<br/> 运行，报错了，找不到授权文件......

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036223182-7832bdef-30af-4fda-806c-cc8b7dc0d58c.png" referrerPolicy="no-referrer" />

<br/> 下载 [https://github.com/Twi1ight/CSAgent](https://github.com/Twi1ight/CSAgent) 解压复制到 out/artifacts/xx/ 下，跟构建出来的jar同级。

编辑 配置选项，追加虚拟机选项：

```bash
-javaagent:D:\JavaProject\ChangeCS\out\artifacts\ChangeCS_jar\CSAgent.jar=5e98194a01c6b48fa582a6a9fcbb92d6 -Duser.language=en
```

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036223620-203873cd-e1da-4e79-81a1-85a562de45c1.png" referrerPolicy="no-referrer" />

<br/> 不出意外运行后就结束退出了。。。 

这是因为触发了暗桩 ：[去除暗桩](https://github.com/lovechoudoufu/cobaltstrike4.4_cdf#去除暗桩)


### 0x03 去除暗桩

通过IDEA复制 beacon/BeaconData.java 到项目src下，将shouldPad方法的值改为false

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036224310-258aec27-6ddb-4f13-95e8-ea902e61ef3c.png" referrerPolicy="no-referrer" />

<br/> 注释 common/Helper.java 31~51行。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036224687-58a14ed8-48a0-495b-8019-a7065a9407e2.png" referrerPolicy="no-referrer" />

<br/> common/Starter.java 11~13行。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036225363-9b7b1890-635d-4f9c-86c2-472610a7fc50.png" referrerPolicy="no-referrer" />

<br/> common/Starter2.java 12~14行。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036225743-1e8df97d-4e78-4747-8e24-570856039133.png" referrerPolicy="no-referrer" />

<br/> 重新构建，即可正常运行，弹出hello CS，确定后出现CS登录页面。


### 0x04 去除水印

修改 common/ListenerConfig.java ，注释掉49行，添加 `var3.append((char)CommonUtils.rand(255));` <br/> 

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036226432-60d545e6-3a0e-4f02-8992-15264d818d02.png" referrerPolicy="no-referrer" />


### 0x05 修改stager

checksum8 脚本

```java
public class EchoSum {
    public static long checksum8(String text) {
        if (text.length() < 4) {
            return 0L;
        }
        text = text.replace("/", "");
        long sum = 0L;
        for (int x = 0; x < text.length(); x++) {
            sum += text.charAt(x);
        }

        return sum;
    }

    public static void main(String[] args) throws Exception {
        System.out.println("x86: " + checksum8("f796xxx.js")); // 可自行修改
        System.out.println("x64: " + checksum8("dd83xxx.js")); // 可自行修改
    }
}
```

[https://www.tutorialspoint.com/compile_java_online.php](https://www.tutorialspoint.com/compile_java_online.php)

运行得到：1270、1396

修改 cloudstrike/webserver.java 175、179、183行，替换，以及删除183行的 && uri.matches("/[A-Za-z0-9]{4}")

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036226859-60ebdf43-b89e-4e87-862b-e1fba03bdd43.png" referrerPolicy="no-referrer" />

<br/> 添加个判断，防止不规范路径泄露stage以及修复log4j2漏洞：

```java
if (!uri.startsWith("/")) {
    return this.processResponse(uri, method, header, param, false, (WebService)null, new Response("400 Bad Request", "text/plain", ""));
}
```

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036227854-66f4db9f-e5d9-465d-aeac-ee9440c5b948.png" referrerPolicy="no-referrer" />

<br/> 修改 common/CommonUtils.java

1385行 return var2.toString(); 为 return "f796xxx.js;", 1400行 return var1; 为 return dd83xxx.js;

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036228971-7d50708d-7e2a-4634-b1d1-b980d36e4a78.png" referrerPolicy="no-referrer" />

<br/> 重新构建jar包会报错，删除报错变量：int len$;、String[] 、WebService service; 即可。


### 0x06 修改服务登录接口

修改 teamserver登录接口，防爆破。

在当前项目src新建软件包ssl ，然后 通过IDEA 复制反编译出来的 ssl/SecureServerSocket.java 和 ssl/SecureSocket.java 到当前项目src/ssl下，修改 48879 为其他数字值。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036229733-419ab755-eb94-4df4-a343-40acfe0cce74.png" referrerPolicy="no-referrer" />


### 0x07 解密sleeve资源

用jas502大佬的 [cs_file_decrypt](https://github.com/jas502n/cs_file_decrypt) 解密 sleeve下的dll资源文件。

需要注意的是 CrackSleeve.java 密钥是其他版本CS的，需要修改为 当前版本的。

[cobaltstrike4.4破解方式](https://github.com/lovechoudoufu/cobaltstrike4.4_cdf#破解方式)

```java
94, -104, 25, 74, 1, -58, -76, -113, -91, -126, -90, -87, -4, -69, -110, -42
```

完整 CrackSleeve.java

```java
import common.*;
import dns.SleeveSecurity;

import java.io.*;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;


public class CrackSleeve {
    private static byte[] OriginKey = {94, -104, 25, 74, 1, -58, -76, -113, -91, -126, -90, -87, -4, -69, -110, -42};
    private static byte[] CustomizeKey = null;

    private String DecDir = "cs44Resource/Decode/sleeve";
    private String EncDir = "cs44Resource/Encode/sleeve";



    public static String bytesToHex(byte[] data) {
        char[] hex = new char[32];
        for (int i = 0; i < 16; i++) {
            int di = data[i];
            hex[i << 1] = Character.forDigit((di >> 4) & 15, 16);
            hex[(i << 1) + 1] = Character.forDigit(di & 15, 16);
        }
        return new String(hex);
    }

    public static byte[] hex2bytes(String var0) {
        int var1 = var0.length();
        byte[] var2 = new byte[var1 / 2];

        for (int var3 = 0; var3 < var1; var3 += 2) {
            var2[var3 / 2] = (byte) ((Character.digit(var0.charAt(var3), 16) << 4) + Character.digit(var0.charAt(var3 + 1), 16));
        }

        return var2;
    }

    public static byte[] Generate_Key() {
        java.security.SecureRandom random = new java.security.SecureRandom();
        byte[] PrivateBytes = new byte[16];
        random.nextBytes(PrivateBytes);
        String Random_Keys = java.util.Arrays.toString(PrivateBytes);
        System.out.println("[-] Example: \n[*] Random_Keys= " + Random_Keys);
        return PrivateBytes;
    }


    public static void main(String[] args) throws IOException {
        if (args.length == 0 || args[0].equals("-h") || args[0].equals("--help")) {
            System.out.println("UseAge: CrackSleeve OPTION [key]");
            System.out.println("Options:");
            System.out.println("\tdecode\t\tDecode sleeve files");
            System.out.println("\tencode\t\tEncode sleeve files");
            System.out.println("\tkey\t\tCustomize key string for encode sleeve files");
            System.exit(0);
        }
        String option = args[0];
        if (option.toLowerCase().equals("encode")) {
            if (args.length <= 1) {
                System.out.println("[-] Please enter key.");
                byte[] Customize_key = Generate_Key();
                System.out.println("[*] Random_Keys Hash =>> " + bytesToHex(Customize_key));
                System.out.printf("[*] $ java -cp cobaltstrike.jar:. CrackSleeve encode %s \n", bytesToHex(Customize_key) +"\n");
                System.exit(0);
            }
            String CustomizeKeyStr = args[1];
            if (CustomizeKeyStr.length() < 16) {
                System.out.println("[-] key length must be 16.");
                System.exit(0);
            }
            System.out.println("Init Key: " + CustomizeKeyStr.substring(0, 32));
//            CustomizeKey = CustomizeKeyStr.substring(0,16).getBytes();
            CustomizeKey = hex2bytes(CustomizeKeyStr.substring(0, 32));
        }


        CrackSleeve Cracker = new CrackSleeve();
        // 使用正版key初始化SleeveSecurity中的key
        if (option.equals("decode")) {
            CrackSleevedResource.Setup(OriginKey);
            Cracker.DecodeFile();
        } else if (option.equals("encode")) {
            CrackSleevedResource.Setup(CustomizeKey);
            Cracker.EncodeFile();
        }
    }

    private void DecodeFile() throws IOException {
        // 文件保存目录
        File saveDir = new File(this.DecDir);
        if (!saveDir.isDirectory()) {
            saveDir.mkdirs();
        }

        // 获取jar文件中sleeve文件夹下的文件列表
        try {
            String path = this.getClass().getClassLoader().getResource("sleeve").getPath();
            String jarPath = path.substring(5, path.indexOf("!/"));
            Enumeration<JarEntry> jarEnum = new JarFile(new File(jarPath)).entries();
            while (jarEnum.hasMoreElements()) {
                JarEntry Element = jarEnum.nextElement();
                String FileName = Element.getName();
                if (FileName.indexOf("sleeve") >= 0 && !FileName.equals("sleeve/")) {
                    System.out.print("[+] Decoding " + FileName + "......");
                    byte[] decBytes = CrackSleevedResource.DecodeResource(FileName);
                    if (decBytes.length > 0) {
                        System.out.println("Done.");
                        CommonUtils.writeToFile(new File(saveDir, "../" + FileName), decBytes);
                    } else {
                        System.out.println("Fail.");
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    private void EncodeFile() {
        // 文件保存目录
        File saveDir = new File(this.EncDir);
        if (!saveDir.isDirectory()) {
            saveDir.mkdirs();
        }

        // 获取解密文件列表
        File decDir = new File(this.DecDir);
        File[] decFiles = decDir.listFiles();
        if (decFiles.length == 0) {
            System.out.println("[-] There's no file to encode, please decode first.");
            System.exit(0);
        }

        for (File file : decFiles) {
            String filename = decDir.getPath() + "/" + file.getName();
            System.out.print("[+] Encoding " + file.getName() + "......");
            byte[] encBytes = CrackSleevedResource.EncodeResource(filename);
            if (encBytes.length > 0) {
                System.out.println("Done.");
                CommonUtils.writeToFile(new File(saveDir, file.getName()), encBytes);
            } else {
                System.out.println("Fail.");
            }
        }
    }
}

class CrackSleevedResource {
    private static CrackSleevedResource singleton;

    private SleeveSecurity data = new SleeveSecurity();

    public static void Setup(byte[] paramArrayOfbyte) {
        singleton = new CrackSleevedResource(paramArrayOfbyte);
    }

    public static byte[] DecodeResource(String paramString) {
        return singleton._DecodeResource(paramString);
    }

    public static byte[] EncodeResource(String paramString) {
        return singleton._EncodeResource(paramString);
    }

    private CrackSleevedResource(byte[] paramArrayOfbyte) {
        this.data.registerKey(paramArrayOfbyte);
    }

    private byte[] _DecodeResource(String paramString) {
        byte[] arrayOfByte1 = CommonUtils.readResource(paramString);
        if (arrayOfByte1.length > 0) {
            long l = System.currentTimeMillis();
            return this.data.decrypt(arrayOfByte1);
        }
        byte[] arrayOfByte2 = CommonUtils.readResource(paramString);
        if (arrayOfByte2.length == 0) {
            CommonUtils.print_error("Could not find sleeved resource: " + paramString + " [ERROR]");
        } else {
            CommonUtils.print_stat("Used internal resource: " + paramString);
        }
        return arrayOfByte2;
    }

    private byte[] _EncodeResource(String paramString) {
        try {
            File fileResource = new File(paramString);
            InputStream fileStream = new FileInputStream(fileResource);
            if (fileStream != null) {
                byte[] fileBytes = CommonUtils.readAll(fileStream);
                if (fileBytes.length > 0) {
                    byte[] fileEncBytes = this.data.encrypt(fileBytes);
                    return fileEncBytes;
                }
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

CrackSleeve.java 与原版cs jar放同一目录，执行如下命令：

```bash
javac -encoding UTF-8 -classpath cobaltstrike.jar CrackSleeve.java
java -classpath cobaltstrike.jar;./ CrackSleeve decode
```

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036230182-57a270c6-f2b3-4609-94d6-abe6dfd4648c.png" referrerPolicy="no-referrer" />


### 0x08 修改默认密钥


#### BeaconPayload

修改 beacon/BeaconPayload.java 方法 beacon_obfuscate() 中的 46，即 0x2E为其他数字十六进制形式。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036230630-c4a47762-32db-40ac-be5e-7fbe37368d92.png" referrerPolicy="no-referrer" />


#### 修改DLL密钥

需要修改的dll文件：

```basic
beacon.dll
beacon.x64.dll
dnsb.dll
dnsb.x64.dll
pivot.dll
pivot.x64.dll
extc2.dll
extc2.x64.dll
```

IDA分别打开上述文件，搜索0x2e是否为异或行为(xor)，出现则Patch，Alt+I 全局搜索0x2e 进行替换为 BeaconPayload.java 中新的值。注意，32位的dll用32位IDA，64反之一样。

然后，工具栏 Edit--Patch Program--Change byte

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036231014-7d7ecb54-311a-49d7-81e7-ad6af3f54684.png" referrerPolicy="no-referrer" />

<br/> 修改之后 点击 Edit--Patch Program---Apply Patches to input file ，关闭文件，继续修改下一dll文件个。


### 0x09 去除BeaconEye特征

用32位IDA打开 beacon.dll，点Hex View-1视图， 按G 跳转到地址：1000A0B9 ，F2或者右键Edit...

`6A 00` 修改为`6A 08`，00可修改其他值。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036231667-1824ac61-f094-4e9d-b18b-e957a3f7e77a.png" referrerPolicy="no-referrer" />


<br/> 修改之后 点击 Edit--Patch Program--Apply Patches to input file ，关闭文件。

用64位IDA 打开 beacon.x64.dll，按G跳转到地址：`000000018001879B`，右键 Text View

然后IDA左上角 Edit----Patch Program---Assemble 修改指令 xor edx, edx 为 mov edx, esi

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036232075-2b139d5a-8202-4890-afbd-fc4409208bd4.png" referrerPolicy="no-referrer" />

<br/> Edit--Patch Program--Apply Patches to input file


#### 重新加密DLL

修改完dll后重新加密。

```bash
java -classpath cobaltstrike.jar;./ CrackSleeve encode 5e98194a01c6b48fa582a6a9fcbb92d6
```

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036232679-700a2eed-db01-41f4-8c99-de316b7e55a2.png" referrerPolicy="no-referrer" />

<br/> `cs44Resource\Encode\sleeve` 下 会生成重新加密后的DLL。


#### 重新构建CS

CS项目下新建文件夹 resources，并把其设置为资源类型。并且把 cs44Resource\Encode\sleeve 整个文件夹复制进去：

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036233130-7972f000-c41d-48eb-8ffc-5cc36e001aaf.png" referrerPolicy="no-referrer" />

<br/> 把CS原来 MANIFEST.MF 中的内容全部复制到项目 src\META0INF\MANIFEST.MF，替换。

构建->构建工件->重新构建，生成新cs jar包。

EvilEye、BeaconEye检测结果如下：

未修改前

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036233785-b1918cb2-d7d4-4d1a-bb22-a917556dcd84.png" referrerPolicy="no-referrer" />

<br/> 修改后

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036234225-b4847c77-68f0-47fc-a68d-0cdaca84c541.png" referrerPolicy="no-referrer" />


## 辅助


### 0x01 端口转发

主要还是Nginx/socat 中转，如下图(来自某大佬博客)。详情待实操补充。

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650195744938-d76e3021-a957-4ffb-98bd-388a12dd9138.png" referrerPolicy="no-referrer" />

### 0x02 云函数

略

### 0x03 JA3/S/JARM

找到篇文章：

[https://www.bc-security.org/post/ja3-s-signatures-and-how-to-avoid-them/](https://www.bc-security.org/post/ja3-s-signatures-and-how-to-avoid-them/)

[https://www.vectra.ai/blogpost/c2-evasion-techniques](https://www.vectra.ai/blogpost/c2-evasion-techniques)

好似可以通过修改 TLS 版本，能起到一定的"混淆"作用？

参考 java 文档 ：[https://java.com/en/configure_crypto.html](https://java.com/en/configure_crypto.html)

禁用 TLS 选项：jdk.tls.disabledAlgorithms 

编辑文件 conf/security/java.securitylib/security/java.security 添加或者删除某些tl版本

如windows上java 11 C:\Program Files\Java\jdk-11.0.13\conf\security\java.security

<img src="https://cdn.nlark.com/yuque/0/2022/png/12849280/1650036234806-6178ba84-9d23-4a6c-9205-09248186c871.png" referrerPolicy="no-referrer" />

<br/> 可以把SSLv3、TLSv1、1.1删除，或添加 TLS 1.3。又或者用高版本(11、14、16)java运行 cs服务端。

Reference

[https://wbglil.gitbook.io/cobalt-strike/](https://wbglil.gitbook.io/cobalt-strike/)
[https://lengjibo.github.io/CobaltStrikeCode/](https://lengjibo.github.io/CobaltStrikeCode/)
[https://bewhale.github.io/posts/50202.html](https://bewhale.github.io/posts/50202.html)
[https://www.bilibili.com/read/cv14238932](https://www.bilibili.com/read/cv14238932)
[https://www.anquanke.com/post/id/265090](https://www.anquanke.com/post/id/265090)
[https://hosch3n.github.io/2020/12/16/检测与隐藏Cobaltstrike服务器/](https://hosch3n.github.io/2020/12/16/检测与隐藏Cobaltstrike服务器/)
[https://maka8ka.cc/post/cobaltstrike-4-3-破解-修复暗桩/](https://maka8ka.cc/post/cobaltstrike-4-3-破解-修复暗桩/)
[https://ucasers.cn/对cobaltstrike4.4的简单魔改/](https://ucasers.cn/对cobaltstrike4.4的简单魔改/)

