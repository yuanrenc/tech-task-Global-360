#!/bin/bash
set -e

dnf update -y
dnf install -y docker

## start docker and enable it to start on boot
systemctl start docker
systemctl enable docker

## Pull the latest image
docker pull colinwang847/global360:latest

docker stop global360 || true
docker rm global360 || true

## Run container on port 80
docker run -d --restart always --name global360 -p 80:80 colinwang847/global360:latest
