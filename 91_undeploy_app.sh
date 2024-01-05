#!/bin/bash

kubectl config use-context wc-1-admin@wc-1

kubectl delete -f 02_red1_web1-content.yaml
kubectl delete -f 03_red2_app1-content.yaml
kubectl delete -f 04_blue_app1-content.yaml
kubectl delete -f 11_red1_web1.yaml
kubectl delete -f 12_red2_app1.yaml
kubectl delete -f 13_blue_app1.yaml
kubectl delete -f 01_ns.yaml
docker stop db1 db2

kubectl config use-context wc-2-admin@wc-2

kubectl delete -f 02_red1_web1-content.yaml
kubectl delete -f 03_red2_app1-content.yaml
kubectl delete -f 04_blue_app1-content.yaml
kubectl delete -f 11_red1_web1.yaml
kubectl delete -f 12_red2_app1.yaml
kubectl delete -f 13_blue_app1.yaml
kubectl delete -f 01_ns.yaml
