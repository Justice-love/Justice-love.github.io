#!/usr/bin/env bash
cd /opt/pages/www
nowTime=`date "+%Y%m%d%H%M"`
git pull
git add .
git commit -m $nowTime
git push