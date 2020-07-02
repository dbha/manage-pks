#BOSH_CLIENT_SECRET=BOSH-CLIENT-SECRET \
#nohup bbr deployment  --target BOSH-TARGET \
#--username BOSH-CLIENT  --deployment DEPLOYMENT-NAME \
#--ca-cert PATH-TO-BOSH-SERVER-CERT \
#restore \
#--artifact-path PATH-TO-DEPLOYMENT-BACKUP

nohup bbr deployment \
--target 172.16.1.11 \
--username $BOSH_CLIENT \
--deployment pivotal-container-service-8ac1fa94cb5049a1bd82 \
--ca-cert ./bosh_ca.crt \
restore \
--artifact-path ./pivotal-container-service-8ac1fa94cb5049a1bd82_20200702T042155Z