#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
NODE_DNS=()
while read line; do
    NODE_DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

# Start redis servers
for dns in "${NODE_DNS[@]}";
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns '/usr/local/redis/src/redis-server /usr/local/redis/redis.conf &' &
done

wait

# begin discovery of redis servers
sleep 5

MASTER_DNS=$(head -n 1 tmp/$INSTANCE_NAME/public_dns)
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/redis/join_redis_cluster.sh "${NODE_DNS[@]}" &

echo "Redis Started!"