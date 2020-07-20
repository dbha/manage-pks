#!/bin/bash

NSX_HOST=nsxmgr-01.haas-252.pez.pivotal.io
NSX_ID=
NSX_PASSWORD=

VIRTUAL_SERVER_TEMPLATE=$1

if [ -z $VIRTUAL_SERVER_TEMPLATE ] ; then
  echo "Please Input virtual_server_template"
  echo "Usages: 02_create_lb_virtual_servers_metrics.sh virtual_servers_template_metrics.json"
  exit 0;
fi

curl -k -u $NSX_ID:$NSX_PASSWORD -d @${VIRTUAL_SERVER_TEMPLATE} -X POST "https://$NSX_HOST/api/v1/loadbalancer/virtual-servers?action=create_with_rules" --header 'X-Allow-Overwrite: true' --header 'Content-Type: application/json'  --header 'charset: utf-8' --header 'Accept: application/json'
