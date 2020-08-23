#!/bin/bash

NSX_HOST=nsxmgr-01.haas-205.pez.pivotal.io
NSX_ID=admin
NSX_PASSWORD=xxxxxxxx

VIRTUAL_SERVER_ID=$1
FILE=$2

if [ -z $VIRTUAL_SERVER_ID ] || [ -z $FILE ] ; then
  echo "Please VIRTUAL_SERVER_ID FILE.JSON"
  echo "Usages : 05_update_lb_virtual_servers.sh xxxxxxx-xxxxxx-xxxxxxx-xxxxxx xxxxx.json"
  exit 0;
fi

curl -k -u $NSX_ID:$NSX_PASSWORD -d @${FILE} -X PUT "https://$NSX_HOST/api/v1/loadbalancer/virtual-servers/$VIRTUAL_SERVER_ID" --header 'X-Allow-Overwrite: true' --header 'Content-Type: application/json'  --header 'charset: utf-8' --header 'Accept: application/json'