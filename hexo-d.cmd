@echo off
hexo g && sleep 2 && powershell -Command "& {Remove-Item -Force -Recurse %cd%\public\posts\* -Exclude *.html}" && echo [+] Successfully deleted the picture directory. && sleep 1 && hexo d
