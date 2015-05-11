#!/bin/bash -e
make build 

CID=$(docker run -d osixia/postfix-dovecot:0.1.0)

echo "sudo docker logs $CID"