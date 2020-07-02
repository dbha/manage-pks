#BOSH_CLIENT_SECRET=PKS-UAA-CLIENT-SECRET nohup bbr deployment \
#--all-deployments --target BOSH-TARGET --username PKS-UAA-CLIENT-NAME \
#--ca-cert PATH-TO-BOSH-SERVER-CERT \
#backup [--with-manifest] [--artifact-path]

BOSH_CLIENT_SECRET=xxxxxxxxxx bbr deployment \
--all-deployments \
--target 172.16.1.11 \
--username pivotal-container-service-8ac1fa94cb5049a1bd82 \
--ca-cert /var/tempest/workspaces/default/root_ca_certificate \
backup --with-manifest