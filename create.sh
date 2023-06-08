#!/bin/bash

HOST_IP=$(ipconfig getifaddr en0)

# start containers
for ((i=1; i<=4; i++))
do
  docker run -dit --name router$i --privileged -p $HOST_IP:6363$i:6363 hydrokhoos/ndn-all:arm
  sed -e "s/<host_ip>/$HOST_IP/g" ./topology/nlsr-router$i.conf > nlsr.conf
  docker cp nlsr.conf router$i:/nlsr.conf
done

docker run -dit --name producer --privileged -p $HOST_IP:63635:6363 hydrokhoos/ndn-all:arm
sed -e "s/<host_ip>/$HOST_IP/g" ./topology/nlsr-producer.conf > nlsr.conf
docker cp nlsr.conf producer:/nlsr.conf

docker run -dit --name consumer --privileged -p $HOST_IP:63636:6363 hydrokhoos/ndn-all:arm
sed -e "s/<host_ip>/$HOST_IP/g" ./topology/nlsr-consumer.conf > nlsr.conf
docker cp nlsr.conf consumer:/nlsr.conf

rm nlsr.conf

# start NFD & NLSR
for ((i=1; i<=4; i++))
do
  docker exec -d router$i sh -c "nfd-start 2> /nfd.log"
  sleep 0.1
  docker exec -d router$i sh -c "nlsr -f /nlsr.conf"
done

docker exec -d producer sh -c "nfd-start 2> /nfd.log"
sleep 0.1
docker exec -d producer sh -c "nlsr -f /nlsr.conf"

docker exec -d consumer sh -c "nfd-start 2> /nfd.log"
sleep 0.1
docker exec -d consumer sh -c "nlsr -f /nlsr.conf"

# create faces
docker exec router1 sh -c "nfdc face create tcp4://$HOST_IP:63632"
docker exec router1 sh -c "nfdc face create tcp4://$HOST_IP:63633"
docker exec router1 sh -c "nfdc face create tcp4://$HOST_IP:63635"

docker exec router2 sh -c "nfdc face create tcp4://$HOST_IP:63631"
docker exec router2 sh -c "nfdc face create tcp4://$HOST_IP:63634"

docker exec router3 sh -c "nfdc face create tcp4://$HOST_IP:63631"
docker exec router3 sh -c "nfdc face create tcp4://$HOST_IP:63634"
docker exec router3 sh -c "nfdc face create tcp4://$HOST_IP:63636"

docker exec router4 sh -c "nfdc face create tcp4://$HOST_IP:63632"
docker exec router4 sh -c "nfdc face create tcp4://$HOST_IP:63633"

docker exec producer sh -c "nfdc face create tcp4://$HOST_IP:63631"

docker exec consumer sh -c "nfdc face create tcp4://$HOST_IP:63633"
