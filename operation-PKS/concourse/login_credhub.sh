CREDHUB_HOME=/home/ubuntu/cp-pks/cp-pks-bosh/bosh-1/concourse-main/credhub

#bosh int ./credhub-vars-store.yml --path=/credhub-ca/ca > credhub-ca.ca
#credhub api --server=https://credhub.pksdemo.net:8844 --ca-cert=./credhub-ca.ca
#credhub login  --client-name=concourse_client --client-secret=$(bosh int ./credhub-vars-store.yml --path=/concourse_credhub_client_secret)

##########

#export CREDHUB_CLIENT=172.16.1.152
bosh int $CREDHUB_HOME/credhub-vars-store.yml --path=/credhub-ca/ca > credhub-ca.ca

#credhub api --server=https://credhub.pksdemo.net:8844 --ca-cert=./credhub-ca.ca
credhub login --client-name=concourse_client --server=https://credhub.pksdemo.net:8844 --ca-cert=./credhub-ca.ca --client-secret=$(bosh int $CREDHUB_HOME/credhub-vars-store.yml --path=/concourse_credhub_client_secret)