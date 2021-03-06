#!/bin/bash

set -eux

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

om --env $WORK_DIR/env.yml bosh-env > $WORK_DIR/bosh-env.sh
source $WORK_DIR/bosh-env.sh

PATH_TO_BOSH_SERVER_CERT=$WORK_DIR/bosh_ca.crt
DEPLOYMENT_NAME=$(bosh deployments | grep pivotal-container-service | awk '{print $1}' | grep pivotal-container-service)

SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
TMP_DIR="$WORK_DIR/${SCRIPT_NAME}_${current_date}"

echo $TMP_DIR
mkdir -p $TMP_DIR
pushd $TMP_DIR

    BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bbr deployment \
         --target ${BOSH_ENVIRONMENT} --username ${BOSH_CLIENT} --deployment ${DEPLOYMENT_NAME} \
         --ca-cert ${PATH_TO_BOSH_SERVER_CERT} \
         backup-cleanup

	BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bbr deployment \
		--target ${BOSH_ENVIRONMENT} --username ${BOSH_CLIENT} --deployment ${DEPLOYMENT_NAME} \
		--ca-cert ${PATH_TO_BOSH_SERVER_CERT} \
		pre-backup-check

	BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bbr deployment \
		--target ${BOSH_ENVIRONMENT} --username ${BOSH_CLIENT} --deployment ${DEPLOYMENT_NAME} \
		--ca-cert ${PATH_TO_BOSH_SERVER_CERT} \
		backup --with-manifest ./

popd

export BACKUP_FILE="${BOSH_ENVIRONMENT}_pks_control_plane-backup_${current_date}.tgz"
tar -zcvf $WORK_DIR/$BACKUP_FILE -C $TMP_DIR . --remove-files
