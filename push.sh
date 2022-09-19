#!/usr/bin/env bash
nowTime=`date "+%Y%m%d%H%M"`
git pull
git add .
git commit -m $nowTime
git push