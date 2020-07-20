#!/bin/bash

NSX_HOST=nsxmgr-01.haas-252.pez.pivotal.io
NSX_ID=admin
NSX_PASSWORD=aYrPge7db6cmYWDBIt!

LB_ID=$1

#TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`


if [ -z $LB_ID ]; then
  echo "Please LB_ID"
  echo "Usages : 01_get_lb_virtual_services.sh xxxxxxx-xxxxxx-xxxxxxx-xxxxxx"
  exit 0;
fi

curl -k -u $NSX_ID:$NSX_PASSWORD -X GET "https://$NSX_HOST/api/v1/loadbalancer/services/$LB_ID" -H "X-Allow-Overwrite: true" > ./${LB_ID}_services.json