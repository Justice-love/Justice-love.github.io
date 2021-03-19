.PHONY: build push

push:
	@git push  gitlab master

build: push
	@echo "begin build"
	@git push  gitlab master
	@ssh root@159.75.107.119 "bash /opt/pages/build.sh"
