#!/bin/bash

kubectl config use-context wc-1-admin@wc-1

kubectl delete -f 41_cg_red2_app1.yaml
kubectl delete -f 42_cg_se_interface.yaml
kubectl delete -f 43_cg_red1-web1.yaml
kubectl delete -f 51_acnp_default_rules.yaml
kubectl delete -f 52_acnp_inter_ns_red.yaml
kubectl delete -f 53_acnp_db_red.yaml
kubectl delete -f 54_acnp_se_red.yaml
