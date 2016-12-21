#
#   Author: Rohith
#   Date: 2015-12-16 14:39:27 +0000 (Wed, 16 Dec 2015)
#
#
NAME=kube-coreos
REGISTRY ?= quay.io
AUTHOR ?= gambol99
VERSION ?= latest

default: build

build:
	docker build -t ${REGISTRY}/${AUTHOR}/${NAME}:${VERSION} .
