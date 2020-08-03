#!/bin/bash

#PKS_CONTROL_PLANE_DEPLOYMENT_NAME=$1
ARTIFACT_PATH=$1

if [ -z ${ARTIFACT_PATH} ] ; then
  echo "Please Input ARTIFACT_PATH"
  exit 0;
fi

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

om --env $WORK_DIR/env.yml bosh-env > $WORK_DIR/bosh-env.sh
source $WORK_DIR/bosh-env.sh

PATH_TO_BOSH_SERVER_CERT=$WORK_DIR/bosh_ca.crt
PKS_CONTROL_PLANE_DEPLOYMENT_NAME=$(bosh deployments | grep pivotal-container-service | awk '{print $1}' | grep pivotal-container-service)

SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
TMP_DIR="$WORK_DIR/${SCRIPT_NAME}_${current_date}"

PKS_UAA_CLIENT_SECRET="19ae9c756428a435a922"
PKS_UAA_CLIENT_NAME=${DEPLOYMENT_NAME}

echo "-----------------"
echo ${WORK_DIR}/${ARTIFACT_PATH}
echo ${PKS_CONTROL_PLANE_DEPLOYMENT_NAME}

BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} \
nohup bbr deployment  --target ${BOSH_ENVIRONMENT}\
--username ${BOSH_CLIENT}  --deployment ${PKS_CONTROL_PLANE_DEPLOYMENT_NAME} \
--ca-cert ${PATH_TO_BOSH_SERVER_CERT} \
restore \
--artifact-path ${WORK_DIR}/${ARTIFACT_PATH}