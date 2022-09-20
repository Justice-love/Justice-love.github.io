#!/usr/bin/env bash
cd /opt/pages/www || exit
nowTime=`date "+%Y%m%d%H%M"`
git pull
git add .
git commit -m $nowTime
echo "begin push"
git push