.PHONY: build push

push:
	@git pull gitlab master:master
	@git push  gitlab master:master

build: push
	@echo "begin build"
	@ssh root@tencent-cvm.com "bash /opt/pages/build.sh"
