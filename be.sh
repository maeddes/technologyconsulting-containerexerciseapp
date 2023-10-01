mvn clean install -Dmaven.test.skip=true -f todobackend/pom.xml
docker build -f Dockerfile-todobackend-otel -t maeddes/todobackend:otel .
