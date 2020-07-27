BIN_DIR=/home/ubuntu/cp-pks/cp-pks-bosh/bosh-1
bosh int $BIN_DIR/creds.yml  --path /director_ssl/ca > $BIN_DIR/director.ca
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int $BIN_DIR/creds.yml --path /admin_password`
export BOSH_CA_CERT=$BIN_DIR/director.ca
export BOSH_ENVIRONMENT=172.16.1.150