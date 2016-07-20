#
#   Author: Rohith
#   Date: 2015-12-16 14:39:27 +0000 (Wed, 16 Dec 2015)
#
#

default: docker

build:
	docker ps

docker:
	docker build -t docker.io/gambol99/kube-coreos .
