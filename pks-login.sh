# PKS-API is the domain name of your PKS API server
PKS_API=api.run.haas-252.pez.pivotal.io
USER_ID=$1
USER_PASSWORD=$2

# CERTIFICATE_PATH is the path to your Ops Manager root CA certificate.
# Provide this certificate to validate the PKS API certificate with SSL.
# /var/tempest/workspaces/default/root_ca_certificate

# If you downloaded the Ops Manager root CA certificate to your machine,
# specify the path where you stored the certificate.
# Save the certificate content to a file called “api.crt” on the opsmgr-02 VM.
CERTIFICATE_PATH=$YOUR_LOCAL_PATH/api.crt

# with CA certificate
tkgi login -a $PKS_API -u $USER_ID -p $USER_PASSWORD --ca-cert $CERTIFICATE_PATH

# Without CA certificate
tkgi login -a $PKS_API -u $USER_ID -p $USER_PASSWORD -k
