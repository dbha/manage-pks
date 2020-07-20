#!/bin/bash

NSX_HOST=nsxmgr-01.haas-252.pez.pivotal.io
NSX_ID=
NSX_PASSWORD=
VIRTUAL_SERVER_ID=$1

if [ -z $VIRTUAL_SERVER_ID ]; then
  echo "Please VIRTUAL_SERVER_ID"
  echo "Usages : 02_delete_lb_virtual_servers.sh xxxxxxx-xxxxxx-xxxxxxx-xxxxxx"
  exit 0;
fi

curl -k -X DELETE "https://$NSX_HOST/api/v1/loadbalancer/virtual-servers/$VIRTUAL_SERVER_ID" -u $NSX_ID:$NSX_PASSWORD --header 'X-Allow-Overwrite: true'
