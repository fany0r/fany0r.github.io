@echo off
hexo -g && sleep 1 && powershell -Command "& {Remove-Item -Force -Recurse %cd%\public\posts\* -Exclude *.html}" && echo [+] Successfully deleted the picture directory. && sleep 0.5 && hexo -d
