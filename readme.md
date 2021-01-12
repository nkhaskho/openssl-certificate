
clone this repository 
```bat
$ git clone https://github.com/naiim-khaskhoussi/openssl-certificate.git
```

# create key and certificate for the entreprise

## step 1: create the entreprise key

```bat
$ openssl genrsa -out ca/tekup.key -des3 4096
```
you will be promped to protect the key with a password

## step 2: create the entreprise certificate
we will make some change to the openssl_ca.cnf under conf directory ()
```bat
openssl req -new -x509 -key ca/tekup.key -out ca/tekup.crt -config config/openssl_ca.cnf -days 3650 -set_serial 0xFFFF
```

to decrypt read the certificate content
```bat
mkdir openssl x509 -in  ca/tekup.crt -text -noout | more
```

# create key and certificate for the user
## step 3
for each user we have to create a new directory for this user under certs
```bat
mkdir certs/naiim
```

the create a key for this user (same as entreprise key)
```bat
openssl genrsa -out certs/naiim/naiim.key -des3 2048
```

## step 4
create user request (standard pk1610)
edit config file openssl_user.cnf
change certificate, and private key
under [ config ]
change O, CN and emailAddress
```bat
openssl req -new -key certs/naiim/naiim.key -out certs/naiim/naiim.req -config config/openssl_user.cnf
```

to see the content of the req file
```bat
openssl req -in certs/naaiim/naiim.req -text -noout | more
```

## step 5
sign the user request by the entreprise
```bat
openssl ca -in certs/naiim/naiim.req -out certs/naiim/naiim.crt -config openssl_ser.cnf
```

for each signed certificate a line added to the index/index.txt file (openssl database)

## step6 
create pkcs12 
```bat
openssl pkcs12 -export -inkey certs/naiim/naiim.key -in certs/naiim/naiim.crt -certfile ca/tekup.crt -out certs/naiim/naiim.pk12 -name "NAIIM"
```

PIN password: 1234
