bbr deployment \
--target 172.16.1.11 \
--username $BOSH_CLIENT \
--deployment service-instance_924c23a4-2c30-49f7-8ea3-48548c06f8f6 \
--ca-cert ./bosh_ca.crt \
backup-cleanup

sleep 1

BOSH_CLIENT_SECRET=xxxxxxxxxxxxxx bbr deployment \
--target 172.16.1.11 \
--username pivotal-container-service-ad56f7d867fa1365e42d \
--deployment service-instance_924c23a4-2c30-49f7-8ea3-48548c06f8f6 \
--ca-cert /var/tempest/workspaces/default/root_ca_certificate \
backup --with-manifest