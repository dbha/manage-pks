#BOSH_CLIENT_SECRET=BOSH-CLIENT-SECRET bbr deployment \
#--target BOSH-TARGET  --username BOSH-CLIENT --deployment DEPLOYMENT-NAME \  BOSH-CLIENT=Credentials > Bosh Commandline Credentials
#--ca-cert PATH-TO-BOSH-SERVER-CERT \
#pre-backup-check

bbr deployment \
--target 172.16.1.11 --username ops_manager \
--deployment pivotal-container-service-8ac1fa94cb5049a1bd82 \
--ca-cert ./bosh_ca.crt \
pre-backup-check