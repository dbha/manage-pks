#!/bin/bash

velero install  --provider aws --bucket velero \
  --secret-file ./credentials-velero --use-volume-snapshots=false \
  --plugins velero/velero-plugin-for-aws:v1.0.1 --use-restic \
  --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://172.16.1.12:9000,publicUrl=http://172.16.1.12:9000

