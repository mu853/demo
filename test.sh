#!/bin/bash

web1_pod1_name=$(kubectl get pods -n red1 -o yaml | yq '.items[0].metadata.name')
web1_pod1_ip=$(kubectl get pods -n red1 $web1_pod1_name -o jsonpath='{.status.podIP}')
web1_pod2_name=$(kubectl get pods -n red1 -o yaml | yq '.items[1].metadata.name')
web1_pod2_ip=$(kubectl get pods -n red1 $web1_pod2_name -o jsonpath='{.status.podIP}')

echo "*** test 1: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> red1/web1 ($web1_pod2_name/$web1_pod2_ip)"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${web1_pod2_ip}"

app1_pod1_name=$(kubectl get pods -n red2 -o yaml | yq '.items[0].metadata.name')
app1_pod1_ip=$(kubectl get pods -n red2 $app1_pod1_name -o jsonpath='{.status.podIP}')

echo "*** test 2: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> red2/app1 ($app1_pod1_name/$app1_pod1_ip)"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${app1_pod1_ip}"

echo "*** test 3: red2/app1 ($app1_pod1_name/$app1_pod1_ip) -> db (192.168.10.10:1521)"
kubectl exec -n red2 $app1_pod1_name -- curl -s --connect-timeout 1 "http://192.168.10.10:1521"

web1_svc_ip=$(kubectl get svc -n red1 web1 -o jsonpath='{.status.loadBalancer.ingress[].ip}')

echo "*** test 4: client (192.168.10.10) -> red1/web1.svc ($web1_svc_ip)"
curl -s --connect-timeout 1 http://${web1_svc_ip}

blue_app1_pod1_name=$(kubectl get pods -n blue -o yaml | yq '.items[0].metadata.name')
blue_app1_pod1_ip=$(kubectl get pods -n blue $blue_app1_pod1_name -o jsonpath='{.status.podIP}')

echo "*** test 5: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> blue/app1 ($blue_app1_pod1_name/$blue_app1_pod1_ip))"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${blue_app1_pod1_ip}"

blue_app1_svc_ip=$(kubectl get svc -n blue app1 -o jsonpath='{.status.loadBalancer.ingress[].ip}')

echo "*** test 6: client (192.168.10.10) -> blue/app1.svc ($blue_app1_svc_ip)"
curl -s --connect-timeout 1 http://${blue_app1_svc_ip}

echo "*** test 7: red2/app1 ($app1_pod1_name/$app1_pod1_ip) -> db (192.168.10.10:3306)"
kubectl exec -n red2 $app1_pod1_name -- curl -s --connect-timeout 1 "http://192.168.10.10:3306"
