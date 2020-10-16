#/bin/sh
set -e

TODO call deployment artifacts and service chapter scripts
Check the state of svc, pods and deployment
if [ -z "$POD" ] ;
then
    echo "Error with deployment" ;
    exit 1;
fi
( 

set -x


status=$?
    [ $status -eq 0 ] && echo "label chapter is successful" || exit $status
)
