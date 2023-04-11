---
title: Windows下配置安装GOAD
tags:
  - GOAD
  - 环境搭建
categories:
  - 杂项
copyright: true
index_img: >-
  https://ghproxy.com/https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/docs/img/GOAD.png
banner_img: >-
  https://ghproxy.com/https://raw.githubusercontent.com/Orange-Cyberdefense/GOAD/main/docs/img/GOAD.png
abbrlink: ad6be596
date: 2023-02-15 22:29:45
---

### 0x01 环境

Win10：Vagrant+VMware Workstation Pro

Vagrant和Vagrant VMware Utility都需要安装。

https://developer.hashicorp.com/vagrant/downloads/vmware

### 0x02 操作

- 修改Vagrant box默认位置

  vagrant下载的box默认保存在 `C:\Users\.vagrant.d` ，会很占用系统盘。通过设置 `VAGRANT_HOME` 环境变量改变保存位置。

```bash
# 用户级别
setx VAGRANT_HOME "E:\VagrantBox"
# 系统级别
setx VAGRANT_HOME "E:\VagrantBox" /M
```

- Clone GOAD仓库

  保存到和VAGRANT_HOME同一磁盘下，因为执行 vagrant up后，GOAD会占用28G左右的空间大小。

`git clone https://github.com/Orange-Cyberdefense/GOAD`

- 安装vmware-desktop插件

  下载很慢，最好扶一下梯子。

```bash
cd GOAD
vagrant plugin install vagrant-vmware-desktop
```

- 修改 Vagrantfile

  改为调用VMware创建虚拟机

```yaml
# Uncomment this depending on the provider you want to use
#ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'
 ENV['VAGRANT_DEFAULT_PROVIDER'] = 'vmware_desktop'
```

顺带修改下CPU与内存，电脑足够强可不修改，默认即可。

```yaml
config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "4096"
    v.vmx["numvcpus"] = "1"
  end
```

- 修改ansible\hosts 

  注释 29-30行，开启33-34行

```yacas
; adapter created by vagrant and virtualbox (comment if you use vmware)
; nat_adapter=Ethernet
; domain_adapter=Ethernet 2

; adapter created by vagrant and vmware (uncomment if you use vmware)
nat_adapter=Ethernet0
domain_adapter=Ethernet1
```

- 构建VM

  执行 `vagrant up` 创建并下载五个虚拟机。漫长的等待后显示以下内容，即表示所有vm已成功创建并运行。

```sqlite
......
......
==> SRV03: Machine booted and ready!
==> SRV03: Configuring network adapters within the VM...
==> SRV03: Configuring secondary network adapters through VMware
==> SRV03: on Windows is not yet supported. You will need to manually
==> SRV03: configure the network adapter.
==> SRV03: Running provisioner: shell...
    SRV03: Running: vagrant/Install-WMF3Hotfix.ps1 as C:\tmp\vagrant-shell.ps1
==> SRV03: Running provisioner: shell...
    SRV03: Running: vagrant/ConfigureRemotingForAnsible.ps1 as C:\tmp\vagrant-shell.ps1
    SRV03: Self-signed SSL certificate generated; thumbprint: 10A4A09077263394BE1DD002F54D8342A239E284
    SRV03:
    SRV03:
    SRV03: wxf                 : http://schemas.xmlsoap.org/ws/2004/09/transfer
    SRV03: a                   : http://schemas.xmlsoap.org/ws/2004/08/addressing
    SRV03: w                   : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
    SRV03: lang                : en-US
    SRV03: Address             : http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous
    SRV03: ReferenceParameters : ReferenceParameters
    SRV03:
    SRV03: Ok.
    SRV03:
    SRV03:
    SRV03:
==> SRV03: Running provisioner: shell...
    SRV03: Running: vagrant/fix_ip.ps1 as C:\tmp\vagrant-shell.ps1
    SRV03:
```

- 添加虚拟机到Vmware控制页面

  vnagrant创建完所有虚拟机会自动运行，但并不会添加到VMware中，需要手动添加才能看到（可不添加，添加到Vmware中只是为了直观看到虚拟机已经在运行）。

`VMware 文件 -> 扫描虚拟机 `，位置选GOAD的machines，即：`E:\GOAD\.vagrant\machines`，结果如下图：

![vm lists](https://cdnjson.com/images/2023/04/11/image-20230215225429968.png)

### 0x03 运行ansible配置环境

- 手动新建一个Linux虚拟机直接运行ISO镜像无需安装（parrot os）
- 给Linux再添加一张仅主机模式网卡（Vmnet2）
- 把物理机上的 GOAD整个文件夹(不包括.vagrant)打包传到新建的 Linux中，执行：

```bash
cd GOAD/ansible
sudo apt install python3.9-venv
python3 -m pip install virtualenv
python3.9 -m virtualenv .venv
source .venv/bin/activate
python3 -m pip install ansible-core==2.12.6
python3 -m pip install pywinrm
```

- 安装ansinle-galaxy依赖

```bash
ansible-galaxy install -r requirements.yml
```

- 执行ansible开始配置环境

```bash
ansible-playbook main.yml
```

执行ansible配置环境需要很漫长的等待，并且很容报各种错误。报错原因无非就是网络问题以及虚拟机配置不足产生的。提高下配置，科学上网，然后反复执行ansible，直到没有红色报错即表示环境配置完成。

![ansible](https://cdnjson.com/images/2023/04/11/image-20230217010325229.png)

配置完后，给攻击机配个网络让其连通环境即可开撸。



Reference

https://xz.aliyun.com/t/12137

https://github.com/Orange-Cyberdefense/GOAD
