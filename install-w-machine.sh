#!/bin/bash
docker-machine rm manager --force
docker-machine rm agent1 --force
docker-machine rm agent2 --force
docker-machine create -d virtualbox manager &
docker-machine create -d virtualbox agent1 &
docker-machine create -d virtualbox agent2 &
wait %1 %2 %3

eval $(docker-machine env manager)
clusterId=$(docker run --rm swarm create | tail -n1)

docker-machine ssh manager "docker run -d -p 3376:3376 -t -v /var/lib/boot2docker:/certs:ro swarm manage -H 0.0.0.0:3376 --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/server.pem --tlskey=/certs/server-key.pem token://$clusterId"

eval $(docker-machine env agent1)
docker-machine config agent1
docker run -d swarm join --addr=$(docker-machine ip agent1):2376 token://$clusterId

eval $(docker-machine env agent2)
docker-machine config agent2
docker run -d swarm join --addr=$(docker-machine ip agent2):2376 token://$clusterId

eval $(docker-machine env manager)
DOCKER_HOST=$(docker-machine ip manager):3376
docker info
docker ps
docker run hello-world
docker ps -a

#docker-machine rm manager --force
#docker-machine rm agent1 --force
#docker-machine rm agent2 --force
