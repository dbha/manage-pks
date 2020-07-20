openssl genrsa -out private.key 2048
openssl rsa -in private.key -pubout -out public.key

openssl req -new -key private.key -out private.csr -config ssl.conf -extensions req_ext

#openssl req -x509 -days 365 private.key -in private.csr -out loginsight.crt -days 365 -config ssl.conf
openssl req -x509 -days 365 -key private.key -in private.csr -out loginsight.crt -days 365 -config ssl.conf -extensions req_ext

#useful
openssl x509 -text -in xxx.crt

# from CRT to PEM
openssl x509 -in xxx.crt -out xxx.pem -outform PEM
