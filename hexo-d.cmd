@echo off
.\node_modules\.bin\hexo.cmd clean && .\node_modules\.bin\hexo.cmd g && sleep 2 && powershell -Command "& {Remove-Item -Force -Recurse '%cd%\public\posts\*' -Exclude *.html; Write-Host '[+] Successfully deleted the picture directory. ' -Fore red}" && sleep 2 && .\node_modules\.bin\hexo.cmd d
