#!/bin/sh
set -e
hexo g
sleep 3
shopt -s extglob
cd public/posts
rm -rf !(*.html)
echo "\033[31m[+] Successfully deleted the picture directory.\033[0m"
sleep 3
hexo d
