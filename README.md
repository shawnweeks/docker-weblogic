# docker-weblogic

To build and push run the following commands.

```shell
docker build -t 249116421948.dkr.ecr.us-east-1.amazonaws.com/weblogic:10.3.6 .
docker push 249116421948.dkr.ecr.us-east-1.amazonaws.com/weblogic:10.3.6

docker build -t 249116421948.dkr.ecr.us-east-1.amazonaws.com/weblogic-base-domain:10.3.6 ./base-domain
docker push 249116421948.dkr.ecr.us-east-1.amazonaws.com/weblogic-base-domain:10.3.6
```
To run the WebLogic Admin Instance do this.

```shell
docker volume create wlsadmin

docker run -it --rm \
    -p 7001:7001 \
    --name wlsadmin \
    --mount source=wlsadmin,target=/u01/oracle/weblogic/user_projects/domains/base_domain/ \
    --env USER_MEM_ARGS='-Xms1024m -Xmx1024m -XX:MaxPermSize=128m' \
    weblogic:10.3.6
```

To run the Node Manager Instance

```shell
docker volume create wlsnode

docker run -it --rm \
    -p 7002:7002 \
    -p 5556:5556 \
    --name wlsnode \
    --mount source=wlsnode,target=/u01/oracle/weblogic/user_projects/domains/base_domain/ \
    --env USER_MEM_ARGS='-Xms1024m -Xmx1024m -XX:MaxPermSize=128m' \
    weblogic:10.3.6 \
    startNodeManager.sh
```