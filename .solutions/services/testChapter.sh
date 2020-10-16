#/bin/sh
set -e
cd ../applications/
./testChapter.sh
cd ../services/
kubectl apply -f todoui-service.yml
kubectl apply -f todobackend-service.yml
export POD=$(kubectl get svc -o name | grep service/todoui); 

if [ -z "$POD" ] ;
then
    echo "Error with services" ;
    exit 1;
fi
( 

set -x
sleep 5
kubectl logs $POD
kubectl apply -f postgres-service.yml
sleep 20
IP=$(kubectl get svc todoui -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo $IP
sleep 20
curl $IP:8090 | head
sleep 5
kubectl expose deployment todoui --type=LoadBalancer --port 80 --target-port=8090 --name=todoui-port80
sleep 20
IP80=$(kubectl get svc todoui-port80 -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
sleep 20
echo $IP80
curl --silent $IP80 | head -n 4
kubectl delete service todoui-port80

echo 'now create reverse-proxy'

kubectl apply -f - <<.EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |-
    user  nginx;
    worker_processes  1;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    events {
        worker_connections  1024;
    }
    http {
        keepalive_timeout  65;
        upstream todoui {
            server todoui:8090; # service name and port of our Kubernetes service
        }
        server {
            listen 80;
            location / {
                proxy_pass         http://todoui;
            }
        }
    }
.EOF

kubectl apply -f - <<.EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: reverseproxy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reverseproxy
  template:
    metadata:
      labels:
        app: reverseproxy
    spec:
      containers:
        - image: nginx:alpine
          name: reverseproxy
          ports:
          - containerPort: 80
          volumeMounts:
          - name: nginx-reverseproxy-config
            mountPath: /etc/nginx/nginx.conf
            subPath: nginx.conf
      volumes:
        - name: nginx-reverseproxy-config
          configMap:
            name: nginx-config
.EOF
kubectl expose deployment reverseproxy --type=LoadBalancer --port 80
sleep 40
IPRP=$(kubectl get svc reverseproxy -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
echo $IPRP
curl --verbose $IPRP | head -n 20
export POD=""
export IP=""
export IP80=""
export IPRP=""

echo "Services is done. State will not removed for the next chapter. If you want this, just execute removeChapterState.sh"

kubectl delete deployment,service reverseproxy
kubectl delete configmap nginx-config

status=$?
    [ $status -eq 0 ] && echo "service chapter is successful" || exit $status
)
