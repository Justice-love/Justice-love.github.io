---
layout: post
title:  "Python版HTTP服务器"
date:   2017-07-25
excerpt: "使用Python创建简单的HTTP服务器"
tag:
- python
- http
comments: true
---

首先确保安装了python。

``` python
python -m SimpleHTTPServer 80
```
后面的80端口是可选的，不填会采用缺省端口8000。注意，这会将当前所在的文件夹设置为默认的Web目录，试着在浏览器敲入本机地址：
```
http://localhost:80
```
如果当前文件夹有```index.html```文件，会默认显示该文件，否则，会以文件列表的形式显示目录下所有文件。

同样，可以基于```SimpleHTTPServer```进行扩展，下面是一个简单的自定义HttpServer
``` python
import SimpleHTTPServer
import SocketServer

PORT = 8000

Handler = SimpleHTTPServer.SimpleHTTPRequestHandler

httpd = SocketServer.TCPServer(("", PORT), Handler)

print "serving at port", PORT
httpd.serve_forever()
```