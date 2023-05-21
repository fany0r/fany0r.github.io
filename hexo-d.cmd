@echo off
hexo clean && hexo g && sleep 2 && powershell -Command "& {Remove-Item -Force -Recurse '%cd%\public\posts\*' -Exclude *.html; Write-Host '[+] Successfully deleted the picture directory. ' -Fore red}" && sleep 2 && hexo d
