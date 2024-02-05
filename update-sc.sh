#!/bin/bash
aws eks --region ap-northeast-2 update-kubeconfig --name tukktukk-prod-infra

kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass tuktuk -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'