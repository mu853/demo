#!/bin/bash

kubectl config use-context wc-1-admin@wc-1

kubectl apply -f 41_cg_red2_app1.yaml
kubectl apply -f 42_cg_se_interface.yaml
kubectl apply -f 43_cg_red1-web1.yaml
kubectl apply -f 44_cg_blue-app1.yaml
kubectl apply -f 51_acnp_default_rules1.yaml
kubectl apply -f 52_acnp_default_rules2.yaml
kubectl apply -f 53_acnp_inter_ns_red.yaml
kubectl apply -f 54_acnp_db_red.yaml
kubectl apply -f 55_acnp_se_red.yaml
kubectl apply -f 56_acnp_fluentbit.yaml
