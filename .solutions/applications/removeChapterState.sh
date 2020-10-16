#/bin/sh
set -x
kubectl delete configmap postgres-config

kubectl delete secret generic db-security 

kubectl delete -f todoui.yml
kubectl delete -f postgres.yml
kubectl delete -f todobackend.yml
export CONFIG=""
export RESTART=""
