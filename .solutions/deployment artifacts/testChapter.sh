#/bin/sh
set -e

kubectl create deployment sampleapp --image=novatec/technologyconsulting-hello-container:v0.1 
kubectl get deploy,rs,po -o wide
export POD=$(kubectl get pods -o name | grep sampleapp); 

if [ -z "$POD" ] ;
then
    echo "Error with deployment" ;
    exit 1;
fi
( 

set -x
sleep 5
kubectl logs $POD
sleep 5
kubectl port-forward $POD 8080:8080 >> /dev/null &
sleep 20
curl localhost:8080/hello
echo 'open bash of ' $POD 
kubectl exec -it $POD -- /bin/bash -c "ls /work"
kubectl delete deployment sampleapp
ps -ef | grep 'kubectl port-forward' |  tr -s ' ' | cut -d ' ' -f 2 | head -1 | xargs kill -9
export POD=""

status=$?
    [ $status -eq 0 ] && echo "deployment chapter is successful" || exit $status
)
