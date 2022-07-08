---
title: VMware Workstation 16 解锁安装 macOS
tags:
  - Cracked
categories:
  - 资源分享
copyright: true
index_img: 'https://s1.ax1x.com/2020/06/27/N6gz9g.md.png'
banner_img: 'https://s1.ax1x.com/2020/06/27/N6gz9g.md.png'
abbrlink: b48cad46
date: 2022-07-03 15:42:17
---


适用 VMware Workstation 11-16、 Player 7-16，理论上 Windows/Linux/Mac都可用。

以下只对Windows下的VMware做了修改，Linux和Mac自测。


win-install.cmd

```vbscript
@echo off
setlocal ENABLEEXTENSIONS
echo.
echo Unlocker 3.0.2 for VMware Workstation
echo =====================================
echo (c) Dave Parsons 2011-18
echo.
echo [+] Set encoding parameters...


echo.
set KeyName="HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player"
:: delims is a TAB followed by a space
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v InstallPath') do set InstallPath=%%B
echo [*] VMware is installed at: %InstallPath%
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v ProductVersion') do set ProductVersion=%%B
echo [*] VMware product version: %ProductVersion%

pushd %~dp0

echo.
echo [*] Stopping VMware services...
net stop "VMwareHostd" > NUL 2>&1
net stop "VMAuthdService" > NUL 2>&1
net stop "VMnetDHCP" > NUL 2>&1
net stop "VMUSBArbService" > NUL 2>&1
net stop "VMware NAT Service" > NUL 2>&1
taskkill /F /IM vmware-tray.exe > NUL 2>&1

echo.
echo [*] Backing up files...
rd /s /q .\backup > NUL 2>&1
mkdir .\backup
mkdir .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-debug.exe" .\backup\x64
xcopy /F /Y "%InstallPath%x64\vmware-vmx-stats.exe" .\backup\x64
xcopy /F /Y "%InstallPath%vmwarebase.dll" .\backup\

echo.
echo [*] Patching...
python.exe .\unlocker.py

echo.
echo [*] Extracting VMware Tools...
python extrtools.py
xcopy /F /Y .\tools\darwin*.* "%InstallPath%"

echo.
echo [*] Starting VMware services...
net start "VMware NAT Service" > NUL 2>&1
net start "VMnetDHCP" > NUL 2>&1
net start "VMAuthdService" > NUL 2>&1
net start "VMUSBArbService" > NUL 2>&1
net start "VMwareHostd" > NUL 2>&1

popd
echo.
echo [+] Finished!
pause

```

win-uninstall.cmd

```vbscript
@echo off
setlocal ENABLEEXTENSIONS
echo.
echo Unlocker 3.0.2 for VMware Workstation
echo =====================================
echo (c) Dave Parsons 2011-18


echo.
set KeyName="HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Player"
:: delims is a TAB followed by a space
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v InstallPath') do set InstallPath=%%B
echo [*] VMware is installed at: %InstallPath%
for /F "tokens=2* delims=	 " %%A in ('REG QUERY %KeyName% /v ProductVersion') do set ProductVersion=%%B
echo [*] VMware product version: %ProductVersion%

pushd %~dp0

echo.
echo [*] Stopping VMware services...
net stop "VMwareHostd" > NUL 2>&1
net stop "VMAuthdService" > NUL 2>&1
net stop "VMnetDHCP" > NUL 2>&1
net stop "VMUSBArbService" > NUL 2>&1
net stop "VMware NAT Service" > NUL 2>&1
taskkill /F /IM vmware-tray.exe > NUL 2>&1

echo.
echo [*] Restoring files...
xcopy /F /Y .\backup\x64\*.* "%InstallPath%x64\"
xcopy /F /Y .\backup\*.* "%InstallPath%"
del /f "%InstallPath%"darwin*.*

echo.
echo [*] Removing backup files...
rd /s /q .\backup > NUL 2>&1

echo.
echo [*] Starting VMware services...
net start "VMware NAT Service" > NUL 2>&1
net start "VMnetDHCP" > NUL 2>&1
net start "VMAuthdService" > NUL 2>&1
net start "VMUSBArbService" > NUL 2>&1
net start "VMwareHostd" > NUL 2>&1

popd
echo.
echo [+] Finished!
pause


```

unlocker.py

```python
#!/usr/bin/env python
"""
The MIT License (MIT)

Copyright (c) 2014-2018 Dave Parsons & Sam Bingner
"""

from __future__ import print_function
import codecs
import os
import re
import struct
import sys

if sys.version_info < (2, 7):
    sys.stderr.write('You need Python 2.7 or later\n')
    sys.exit(1)

# Setup imports depending on whether IronPython or CPython
if sys.platform == 'win32' \
        or sys.platform == 'cli':
    # noinspection PyUnresolvedReferences
    if sys.version_info > (3, 0):
        from winreg import *
    else:
        from _winreg import *



def bytetohex(data):
    if sys.version_info > (3, 0):
        # Python 3 code in this block
        return "".join("{:02X} ".format(c) for c in data)
    else:
        # Python 2 code in this block
        return "".join("{:02X} ".format(ord(c)) for c in data)


def joinpath(folder, filename):
    return os.path.join(folder, filename)


def printkey(i, offset, smc_key, smc_data):
    print(str(i + 1).zfill(3)
          + ' ' + hex(offset)
          + ' ' + smc_key[0][::-1].decode('UTF-8')
          + ' ' + str(smc_key[1]).zfill(2)
          + ' ' + smc_key[2][::-1].replace(b'\x00', b' ').decode('UTF-8')
          + ' ' + '{0:#0{1}x}'.format(smc_key[3], 4)
          + ' ' + hex(smc_key[4])
          + ' ' + bytetohex(smc_data))


def set_bit(value, bit):
    return value | (1 << bit)


def clear_bit(value, bit):
    return value & ~(1 << bit)


def test_bit(value, bit):
    return value & bit


E_CLASS64 = 2
E_SHT_RELA = 4


def patchelf(f, oldoffset, newoffset):
    f.seek(0)
    magic = f.read(4)
    if not magic == b'\x7fELF':
        raise Exception('Magic number does not match')

    ei_class = struct.unpack('=B', f.read(1))[0]
    if ei_class != E_CLASS64:
        raise Exception('Not 64bit elf header: ' + ei_class)

    f.seek(40)
    e_shoff = struct.unpack('=Q', f.read(8))[0]
    f.seek(58)
    e_shentsize = struct.unpack('=H', f.read(2))[0]
    e_shnum = struct.unpack('=H', f.read(2))[0]
    e_shstrndx = struct.unpack('=H', f.read(2))[0]

    print('e_shoff: 0x{:x} e_shentsize: 0x{:x} e_shnum:0x{:x} e_shstrndx:0x{:x}'.format(e_shoff, e_shentsize,
                                                                                        e_shnum, e_shstrndx))

    for i in range(0, e_shnum):
        f.seek(e_shoff + i * e_shentsize)
        e_sh = struct.unpack('=LLQQQQLLQQ', f.read(e_shentsize))
        # e_sh_name = e_sh[0]
        e_sh_type = e_sh[1]
        e_sh_offset = e_sh[4]
        e_sh_size = e_sh[5]
        e_sh_entsize = e_sh[9]
        if e_sh_type == E_SHT_RELA:
            e_sh_nument = int(e_sh_size / e_sh_entsize)
            # print 'RELA at 0x{:x} with {:d} entries'.format(e_sh_offset, e_sh_nument)
            for j in range(0, e_sh_nument):
                f.seek(e_sh_offset + e_sh_entsize * j)
                rela = struct.unpack('=QQq', f.read(e_sh_entsize))
                r_offset = rela[0]
                r_info = rela[1]
                r_addend = rela[2]
                if r_addend == oldoffset:
                    r_addend = newoffset
                    f.seek(e_sh_offset + e_sh_entsize * j)
                    f.write(struct.pack('=QQq', r_offset, r_info, r_addend))
                    print('Relocation modified at: ' + hex(e_sh_offset + e_sh_entsize * j))


def patchkeys(f, key):
    # Setup struct pack string
    key_pack = '=4sB4sB6xQ'
    # smc_old_memptr = 0
    smc_new_memptr = 0

    # Do Until OSK1 read
    i = 0
    while True:

        # Read key into struct str and data byte str
        offset = key + (i * 72)
        f.seek(offset)
        smc_key = struct.unpack(key_pack, f.read(24))
        smc_data = f.read(smc_key[1])

        # Reset pointer to beginning of key entry
        f.seek(offset)

        if smc_key[0] == b'SKL+':
            # Use the +LKS data routine for OSK0/1
            smc_new_memptr = smc_key[4]
            print('+LKS Key: ')
            printkey(i, offset, smc_key, smc_data)

        elif smc_key[0] == b'0KSO':
            # Write new data routine pointer from +LKS
            print('OSK0 Key Before:')
            printkey(i, offset, smc_key, smc_data)
            # smc_old_memptr = smc_key[4]
            f.seek(offset)
            f.write(struct.pack(key_pack, smc_key[0], smc_key[1], smc_key[2], smc_key[3], smc_new_memptr))
            f.flush()

            # Write new data for key
            f.seek(offset + 24)
            smc_new_data = codecs.encode('bheuneqjbexolgurfrjbeqfthneqrqcy', 'rot_13')
            f.write(smc_new_data.encode('UTF-8'))
            f.flush()

            # Re-read and print key
            f.seek(offset)
            smc_key = struct.unpack(key_pack, f.read(24))
            smc_data = f.read(smc_key[1])
            print('OSK0 Key After:')
            printkey(i, offset, smc_key, smc_data)

        elif smc_key[0] == b'1KSO':
            # Write new data routine pointer from +LKS
            print('OSK1 Key Before:')
            printkey(i, offset, smc_key, smc_data)
            smc_old_memptr = smc_key[4]
            f.seek(offset)
            f.write(struct.pack(key_pack, smc_key[0], smc_key[1], smc_key[2], smc_key[3], smc_new_memptr))
            f.flush()

            # Write new data for key
            f.seek(offset + 24)
            smc_new_data = codecs.encode('rnfrqbagfgrny(p)NccyrPbzchgreVap', 'rot_13')
            f.write(smc_new_data.encode('UTF-8'))
            f.flush()

            # Re-read and print key
            f.seek(offset)
            smc_key = struct.unpack(key_pack, f.read(24))
            smc_data = f.read(smc_key[1])
            print('OSK1 Key After:')
            printkey(i, offset, smc_key, smc_data)

            # Finished so get out of loop
            break

        else:
            pass

        i += 1
    return smc_old_memptr, smc_new_memptr


def patchsmc(name, sharedobj):
    with open(name, 'r+b') as f:

        smc_old_memptr = 0
        smc_new_memptr = 0

        # Read file into string variable
        vmx = f.read()

        print('File: ' + name + '\n')

        # Setup hex string for vSMC headers
        # These are the private and public key counts
        smc_header_v0 = b'\xF2\x00\x00\x00\xF0\x00\x00\x00'
        smc_header_v1 = b'\xB4\x01\x00\x00\xB0\x01\x00\x00'

        # Setup hex string for #KEY key
        key_key = b'\x59\x45\x4B\x23\x04\x32\x33\x69\x75'

        # Setup hex string for $Adr key
        adr_key = b'\x72\x64\x41\x24\x04\x32\x33\x69\x75'

        # Find the vSMC headers
        smc_header_v0_offset = vmx.find(smc_header_v0) - 8
        smc_header_v1_offset = vmx.find(smc_header_v1) - 8

        # Find '#KEY' keys
        smc_key0 = vmx.find(key_key)
        smc_key1 = vmx.rfind(key_key)

        # Find '$Adr' key only V1 table
        smc_adr = vmx.find(adr_key)

        # Print vSMC0 tables and keys
        print('appleSMCTableV0 (smc.version = "0")')
        print('appleSMCTableV0 Address      : ' + hex(smc_header_v0_offset))
        print('appleSMCTableV0 Private Key #: 0xF2/242')
        print('appleSMCTableV0 Public Key  #: 0xF0/240')

        if (smc_adr - smc_key0) != 72:
            print('appleSMCTableV0 Table        : ' + hex(smc_key0))
            smc_old_memptr, smc_new_memptr = patchkeys(f, smc_key0)
        elif (smc_adr - smc_key1) != 72:
            print('appleSMCTableV0 Table        : ' + hex(smc_key1))
            smc_old_memptr, smc_new_memptr = patchkeys(f, smc_key1)

        print()

        # Print vSMC1 tables and keys
        print('appleSMCTableV1 (smc.version = "1")')
        print('appleSMCTableV1 Address      : ' + hex(smc_header_v1_offset))
        print('appleSMCTableV1 Private Key #: 0x01B4/436')
        print('appleSMCTableV1 Public Key  #: 0x01B0/432')

        if (smc_adr - smc_key0) == 72:
            print('appleSMCTableV1 Table        : ' + hex(smc_key0))
            smc_old_memptr, smc_new_memptr = patchkeys(f, smc_key0)
        elif (smc_adr - smc_key1) == 72:
            print('appleSMCTableV1 Table        : ' + hex(smc_key1))
            smc_old_memptr, smc_new_memptr = patchkeys(f, smc_key1)

        print()

        # Find matching RELA record in .rela.dyn in ESXi ELF files
        # This is temporary code until proper ELF parsing written
        if sharedobj:
            print('Modifying RELA records from: ' + hex(smc_old_memptr) + ' to ' + hex(smc_new_memptr))
            patchelf(f, smc_old_memptr, smc_new_memptr)

        # Tidy up
        f.flush()
        f.close()


def patchbase(name):
    # Patch file
    print('GOS Patching: ' + name)
    f = open(name, 'r+b')

    # Entry to search for in GOS table
    # Should work for Workstation 12-15...
    darwin = re.compile(
             b'\x10\x00\x00\x00[\x10|\x20]\x00\x00\x00[\x01|\x02]\x00\x00\x00\x00\x00\x00\x00'
             b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')

    # Read file into string variable
    base = f.read()

    # Loop through each entry and set top bit
    # 0xBE --> 0xBF (WKS 12)
    # 0x3E --> 0x3F (WKS 14)
    for m in darwin.finditer(base):
        offset = m.start()
        f.seek(offset + 32)
        flag = ord(f.read(1))
        flag = set_bit(flag, 0)
#        flag = chr(flag)
        f.seek(offset + 32)
        f.write(bytes([flag]))
        print('GOS Patched flag @: ' + hex(offset))

    # Tidy up
    f.flush()
    f.close()
    print('GOS Patched: ' + name)


def patchvmkctl(name):
    # Patch file
    print('smcPresent Patching: ' + name)
    f = open(name, 'r+b')

    # Read file into string variable
    vmkctl = f.read()
    applesmc = vmkctl.find(b'applesmc')
    f.seek(applesmc)
    f.write(b'vmkernel')

    # Tidy up
    f.flush()
    f.close()
    print('smcPresent Patched: ' + name)


# noinspection PyUnresolvedReferences
def main():
    # Work around absent Platform module on VMkernel
    if os.name == 'nt' or os.name == 'cli':
        osname = 'windows'
    else:
        osname = os.uname()[0].lower()

    # vmwarebase = ''
    vmx_so = False

    # Setup default paths
    if osname == 'linux':
        vmx_path = '/usr/lib/vmware/bin/'
        vmx = joinpath(vmx_path, 'vmware-vmx')
        vmx_debug = joinpath(vmx_path, 'vmware-vmx-debug')
        vmx_stats = joinpath(vmx_path, 'vmware-vmx-stats')
        if os.path.isfile('/usr/lib/vmware/lib/libvmwarebase.so/libvmwarebase.so'):
            vmx_so = True
            vmwarebase = '/usr/lib/vmware/lib/libvmwarebase.so/libvmwarebase.so'
        else:
            vmwarebase = '/usr/lib/vmware/lib/libvmwarebase.so.0/libvmwarebase.so.0'

    elif osname == 'windows':
        reg = ConnectRegistry(None, HKEY_LOCAL_MACHINE)
        key = OpenKey(reg, r'SOFTWARE\Wow6432Node\VMware, Inc.\VMware Workstation')
        vmwarebase_path = QueryValueEx(key, 'InstallPath')[0]
        vmx_path = QueryValueEx(key, 'InstallPath64')[0]
        vmx = joinpath(vmx_path, 'vmware-vmx.exe')
        vmx_debug = joinpath(vmx_path, 'vmware-vmx-debug.exe')
        vmx_stats = joinpath(vmx_path, 'vmware-vmx-stats.exe')
        vmwarebase = joinpath(vmwarebase_path, 'vmwarebase.dll')

    else:
        print('Unknown Operating System: ' + osname)
        return

    # Patch the vmx executables skipping stats version for Player
    patchsmc(vmx, vmx_so)
    patchsmc(vmx_debug, vmx_so)
    if os.path.isfile(vmx_stats):
        patchsmc(vmx_stats, vmx_so)

    # Patch vmwarebase for Workstation and Player
    patchbase(vmwarebase)


if __name__ == '__main__':
    main()

```

extrtools.py

```python
#!/usr/bin/env python
"""
需要提前手动创建tools目录，下载com.vmware.fusion.zip.tar保存到tools
https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/
"""

from __future__ import print_function
import os
import sys
import shutil
import tarfile
import zipfile
import time


def convertpath(path):
    # OS path separator replacement funciton
    return path.replace(os.path.sep, '/')

def main():
	# Check minimal Python version is 2.7
	if sys.version_info < (3, 0):
		sys.stderr.write('[!] You need Python 3 or later\n')
		sys.exit(1)

	dest = os.path.dirname(os.path.abspath(__file__))
	
	print('[+] Extracting com.vmware.fusion.zip.tar...')
	tar = tarfile.open(convertpath(dest + '/tools/com.vmware.fusion.zip.tar'), 'r')
	tar.extract('com.vmware.fusion.zip', path=convertpath(dest + '/tools/'))
	tar.close()
	
	print('[+] Extracting files from com.vmware.fusion.zip...')
	cdszip = zipfile.ZipFile(convertpath(dest + '/tools/com.vmware.fusion.zip'), 'r')
	cdszip.extract('payload/VMware Fusion.app/Contents/Library/isoimages/darwin.iso', path=convertpath(dest + '/tools/'))
	cdszip.extract('payload/VMware Fusion.app/Contents/Library/isoimages/darwinPre15.iso', path=convertpath(dest + '/tools/'))
	cdszip.close()
	
	# Move the iso and sig files to tools folder
	shutil.move(convertpath(dest + '/tools/payload/VMware Fusion.app/Contents/Library/isoimages/darwin.iso'), convertpath(dest + '/tools/darwin.iso'))
	shutil.move(convertpath(dest + '/tools/payload/VMware Fusion.app/Contents/Library/isoimages/darwinPre15.iso'), convertpath(dest + '/tools/darwinPre15.iso'))
	
	# Cleanup working files and folders
	shutil.rmtree(convertpath(dest + '/tools/payload'), True)
	# os.remove(convertpath(dest + '/tools/com.vmware.fusion.zip.tar'))
	os.remove(convertpath(dest + '/tools/com.vmware.fusion.zip'))
	
	print('[+] Tools retrieved successfully')
	return


if __name__ == '__main__':
    main()

```

完整UnlockerVMware16脚本包：https://wwp.lanzouy.com/ieZZz07axacd 下载解压。

在win-install.cmd同级目录下创建 tools 文件夹，然后下载 vmware tools包，保存到tools目录下。

下载地址，官网很慢 [com.vmware.fusion.zip.tar](https://softwareupdate.vmware.com/cds/vmw-desktop/fusion/12.2.3/19436697/x86/core/com.vmware.fusion.zip.tar) 

蓝奏云：https://wwp.lanzouy.com/b02df196h 密码:1snz

分卷为7个压缩包，全部下载，删除后缀【.gz】，解压存放到tools目录。

以管理员权限运行 `win-install.cmd` 

![](https://s1.ax1x.com/2022/07/03/j8RxuF.png)


![](https://s1.ax1x.com/2022/07/03/j8RjjU.png)

如需恢复破解，运行 `win-uninstall.cmd`

![](https://s1.ax1x.com/2022/07/03/j8RXcT.png)



Reference

https://github.com/paolo-projects/unlocker
