#!/usr/bin/env bash

#Sample
openssl req -nodes -new -x509 -keyout ca.key -out ca.crt -subj "/CN=Prometheus Demo CA"
openssl genrsa -out harbor-tls.key 2048
openssl req -new -key harbor-tls.key -subj "/CN=*.harbor.pksdemo.net"
openssl req -new -key harbor-tls.key -subj "/CN=*.harbor.pksdemo.net" \
    | openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -out 205.harbor-tls.crt