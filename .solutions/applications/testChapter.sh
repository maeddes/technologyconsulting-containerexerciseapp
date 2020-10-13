#/bin/sh
set -e

kubectl create configmap postgres-config --from-literal=postgres.db.name=mydb

export CONFIG=$(kubectl get configmap -o name | grep postgres-config); 

if [ -z "$CONFIG" ] ;
then
    echo "Error with deployment" ;
    exit 1;
fi
( 

set -x
kubectl create secret generic db-security --from-literal=db.user.name=matthias --from-literal=db.user.password=password
echo "this should output password"
kubectl get secrets db-security -o jsonpath='{.data.db\.user\.password}' | base64 --decode
kubectl apply -f todoui.yml
kubectl apply -f postgres.yml
kubectl apply -f todobackend.yml
sleep 40

export RESTART=$(kubectl get pods --sort-by='.status.containerStatuses[0].restartCount' | grep 'todobackend' | cut -d ' ' -f 12)
echo "Restart count should >0"
if [ $RESTART -le 0 ] ; 
then
    echo "No BACKEND restarts!" ;
    exit 1;
fi
(
kubectl describe deployments todobackend 
kubectl describe pods todobackend
echo "Application is done. State will not removed for the next chapter. If you want this, just execute removeChapterState.sh"

)



status=$?
    [ $status -eq 0 ] && echo "deployment chapter is successful" || exit $status
)
