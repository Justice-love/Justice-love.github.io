---
layout: post
title:  "MySql数据库备份"
date:   2017-03-23
excerpt: "运维相关：mysql数据库备份"
tag:
- mysql
- dump
comments: true
---

### MySql数据库备份
``` shell
#!/bin/sh

DB_NAME="DB"
TABLES=(tableA tableB)
DUMP_DIR="/tmp/dump"
USERNAME="username"
PASSWORD="password"
HOST="host"

function check() {
  if  [ ${#TABLES[*]} -eq 0 ]
  then
    echo "TABLES is null"
    exit 1
  elif [ "$DB_NAME" = "" ]
  then
    echo "DB_NAME is null"
    exit 1
  fi
}

function dump() {
  echo "begin dump $t"
  #touch $DUMP_DIR/$t.sql
  mysqldump -u$USERNAME -p$PASSWORD -h$HOST $DB_NAME $t > $DUMP_DIR/$t.sql
}

case "$1" in
  dump)
    check;
    echo "begin dump database $DB_NAME"
    for t in ${TABLES[@]};
    do
      dump;
    done;
    echo "finish"
    ;;
  *)
    echo "Usage: $0 {dump}"
    exit 1
esac

exit 0


```
