#!/bin/bash

kubectl config use-context wc-1-admin@wc-1

kubectl apply -f 01_ns.yaml
kubectl apply -f 02_red1_web1-content.yaml
kubectl apply -f 03_red2_app1-content.yaml
kubectl apply -f 04_blue_app1-content.yaml
kubectl apply -f 11_red1_web1.yaml
kubectl apply -f 12_red2_app1.yaml
kubectl apply -f 13_blue_app1.yaml
./21_db-server.sh

kubectl config use-context wc-2-admin@wc-2

kubectl apply -f 01_ns.yaml
kubectl apply -f 02_red1_web1-content.yaml
kubectl apply -f 03_red2_app1-content.yaml
kubectl apply -f 04_blue_app1-content.yaml
kubectl apply -f 11_red1_web1.yaml
kubectl apply -f 12_red2_app1.yaml
kubectl apply -f 13_blue_app1.yaml
