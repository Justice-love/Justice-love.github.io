.PHONY: build push

push:
	@git push  gitlab master:master

build: push
	@echo "begin build"
	@git pull gitlab master
	@git push  gitlab master
	@ssh root@tencent-cvm.com "bash /opt/pages/build.sh"
