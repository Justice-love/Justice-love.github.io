.PHONY: build push

push:
	@git push  gitlab master:master

build: push
	@echo "begin build"
	@git push  gitlab master
	@ssh root@******** "bash /opt/pages/build.sh"
