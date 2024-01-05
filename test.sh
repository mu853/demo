#!/bin/bash
kubectl config use-context wc-1-admin@wc-1

## 許可される想定の通信
# 1. NS内通信：red1/web1→red1/web1:80
web1_pod1_name=$(kubectl get pods -n red1 -o yaml | yq '.items[0].metadata.name')
web1_pod1_ip=$(kubectl get pods -n red1 $web1_pod1_name -o jsonpath='{.status.podIP}')
web1_pod2_name=$(kubectl get pods -n red1 -o yaml | yq '.items[1].metadata.name')
web1_pod2_ip=$(kubectl get pods -n red1 $web1_pod2_name -o jsonpath='{.status.podIP}')

echo "*** test 1: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> red1/web1 ($web1_pod2_name/$web1_pod2_ip)"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${web1_pod2_ip}"

# 2. NSまたぎの通信：red1/web1→red2/app1:80
app1_pod1_name=$(kubectl get pods -n red2 -o yaml | yq '.items[0].metadata.name')
app1_pod1_ip=$(kubectl get pods -n red2 $app1_pod1_name -o jsonpath='{.status.podIP}')

echo "*** test 2: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> red2/app1 ($app1_pod1_name/$app1_pod1_ip)"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${app1_pod1_ip}"

# 3. 外部への通信：red/app1→192.168.10.10:1521
echo "*** test 3: red2/app1 ($app1_pod1_name/$app1_pod1_ip) -> db (192.168.10.10:1521)"
kubectl exec -n red2 $app1_pod1_name -- curl -s --connect-timeout 1 "http://192.168.10.10:1521"

# 4. 外部からの通信(個別)：LB 経由→red1/web1:80
web1_svc_ip=$(kubectl get svc -n red1 web1 -o jsonpath='{.status.loadBalancer.ingress[].ip}')

echo "*** test 4: client (192.168.10.10) -> red1/web1.svc ($web1_svc_ip)"
curl -s --connect-timeout 1 http://${web1_svc_ip}

## ブロックされる想定の通信
# 5. NSまたぎの通信：red1/web1→blue/app1:80
blue_app1_pod1_name=$(kubectl get pods -n blue -o yaml | yq '.items[0].metadata.name')
blue_app1_pod1_ip=$(kubectl get pods -n blue $blue_app1_pod1_name -o jsonpath='{.status.podIP}')

echo "*** test 5: red1/web1 ($web1_pod1_name/$web1_pod1_ip) -> blue/app1 ($blue_app1_pod1_name/$blue_app1_pod1_ip))"
kubectl exec -n red1 $web1_pod1_name -- curl -s --connect-timeout 1 "http://${blue_app1_pod1_ip}"

# 6. 外部からの通信：LB 経由→blue/app1:80
blue_app1_svc_ip=$(kubectl get svc -n blue app1 -o jsonpath='{.status.loadBalancer.ingress[].ip}')

echo "*** test 6: client (192.168.10.10) -> blue/app1.svc ($blue_app1_svc_ip)"
curl -s --connect-timeout 1 http://${blue_app1_svc_ip}

# 7. 外部への通信 (許可されていないもの)：red2/app1→192.168.10.10:3306
echo "*** test 7: red2/app1 ($app1_pod1_name/$app1_pod1_ip) -> db (192.168.10.10:3306)"
kubectl exec -n red2 $app1_pod1_name -- curl -s --connect-timeout 1 "http://192.168.10.10:3306"

# 8. クラスタ跨ぎの通信：wc-2/red1/web1→wc-1/red1/web1 (NodePortに対して通信を行う)
node_port=$(kubectl get svc -n red1 web1 -o jsonpath='{.spec.ports[].nodePort}')
node_ip=$(kubectl get nodes -o json | jq '.items[].status.addresses[] | select(.type == "ExternalIP") | .address' | head -1 | tr -d '"')

wc2_web1_pod1_name=$(kubectl --context wc-2-admin@wc-2 get pods -n red1 -o yaml | yq '.items[0].metadata.name')
wc2_web1_pod1_ip=$(kubectl --context wc-2-admin@wc-2 get pods -n red1 $wc2_web1_pod1_name -o jsonpath='{.status.podIP}')

echo "*** test 8: wc-2/red1/web1 ($wc2_web1_pod1_name/$wc2_web1_pod1_ip) -> wc-1/red1/web1/nodePort (${node_ip}:${node_port})"
kubectl --context wc-2-admin@wc-2 exec -n red1 $wc2_web1_pod1_name -- curl -s --connect-timeout 1 "http://${node_ip}:${node_port}"

# 9. クラスタ跨ぎの通信：wc-2/red1/web1→wc-1/red1/web1 (LB VIPに対して通信を行う)
echo "*** test 9: wc-2/red1/web1 ($wc2_web1_pod1_name/$wc2_web1_pod1_ip) -> wc-1/red1/web1/LB (${web1_svc_ip})"
kubectl --context wc-2-admin@wc-2 exec -n red1 $wc2_web1_pod1_name -- curl -s --connect-timeout 1 "http://${web1_svc_ip}"
