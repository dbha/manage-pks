#!/bin/bash

set -eux

current_date="$( date +"%Y-%m-%d-%H-%M-%S" )"

WORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

om --env $WORK_DIR/env.yml bosh-env > $WORK_DIR/bosh-env.sh
source $WORK_DIR/bosh-env.sh

export PRIVATE_KEY_FILE=$WORK_DIR/bosh_private_key.pem

SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
TMP_DIR="$WORK_DIR/${SCRIPT_NAME}_${current_date}"

echo $TMP_DIR
mkdir -p $TMP_DIR
pushd $TMP_DIR

  export BOSH_BBR_ACCOUNT=bbr
  bbr director --host "${BOSH_ENVIRONMENT}" \
	  --username $BOSH_BBR_ACCOUNT \
	  --private-key-path $PRIVATE_KEY_FILE \
	  backup-cleanup
  bbr director --host "${BOSH_ENVIRONMENT}" \
	  --username $BOSH_BBR_ACCOUNT \
	  --private-key-path $PRIVATE_KEY_FILE \
	  pre-backup-check

  bbr director --host "${BOSH_ENVIRONMENT}" \
	  --username $BOSH_BBR_ACCOUNT \
	  --private-key-path $PRIVATE_KEY_FILE \
	  backup

popd

export BACKUP_FILE="${BOSH_ENVIRONMENT}_director-backup_${current_date}.tgz"
tar -zcvf $WORK_DIR/$BACKUP_FILE -C $TMP_DIR . --remove-files