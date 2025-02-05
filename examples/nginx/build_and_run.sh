#!/bin/sh
docker rm -f nginx-example-test
docker build -t telicent-nginx-example .
docker run -d \
    --name nginx-example-test \
    -p 8080:8080 \
    telicent-nginx-example