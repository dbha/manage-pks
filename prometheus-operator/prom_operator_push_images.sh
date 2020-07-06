#!/bin/bash

PROJECT=dbha
REGISTRY=harbor.run.haas-205.pez.pivotal.io

FILE=$1
echo $FILE

if [ -z $FILE ]; then
  echo "prom_operator_push_images.sh operator_images_list"
  exit 0;
fi

for list in `cat ./$FILE`
do
  IMAGE_NAME=$(echo $list | rev | cut -d/ -f1 | rev)
  docker pull $list
  docker tag $list $REGISTRY/$PROJECT/monitoring/$IMAGE_NAME
  docker push $REGISTRY/$PROJECT/monitoring/$IMAGE_NAME
done