# $1 (NOM PRENOM)
# $2 (COMPANY)
# $3 (DEPARTEMENT)
# $4 (ADRESSE EMAIL 1)
# $5 (ADRESSE EMAIL 2)

#!/bin/sh
PKCS12_PASSWORD="1234"
LDAP_PASSWORD="secret"
CLIENT_LDAP_PASSWORD=(`slappasswd -h {SHA} -s $PKCS12_PASSWORD`) 
PATHTOCA="/root/pki"
NAMEFILE=(`echo $1|sed s/\ /_/g`)
PATHCLIENT=$PATHTOCA/certs/$NAMEFILE
rm -rf $PATHCLIENT
mkdir $PATHCLIENT
openssl genrsa -out $PATHCLIENT/$NAMEFILE.key 2048 &>/tmp/gencert_log
OPENSSL_CONFIG="[ config ] \nC = TN \nO = $2 \nOU = $3 \nCN = $1 \nemailAddress = $4"
cat config/openssl.cnf|sed "s/###/$5/g">/tmp/openssl.cnf
echo -e $OPENSSL_CONFIG>>/tmp/openssl.cnf
openssl req -new -key $PATHCLIENT/$NAMEFILE.key -out $PATHCLIENT/$NAMEFILE.req -config /tmp/openssl.cnf
openssl ca -config /tmp/openssl.cnf -in $PATHCLIENT/$NAMEFILE.req -out $PATHCLIENT/$NAMEFILE.crt -batch &>/tmp/gencert_log
openssl x509 -outform DER -in $PATHCLIENT/$NAMEFILE.crt -out $PATHCLIENT/$NAMEFILE.der
openssl pkcs12 -export -inkey $PATHCLIENT/$NAMEFILE.key -in $PATHCLIENT/$NAMEFILE.crt -out $PATHCLIENT/$NAMEFILE.p12 -certfile ca/icasa.crt -name "$1"  
SERIAL=(`openssl x509 -in $PATHCLIENT/$NAMEFILE.crt -serial -noout | sed s/serial=//`)
LDIF_ORG="dn: o=$2,dc=certification,dc=com\nobjectClass: organization\nobjectClass: top\ndescription: $2\no: $2"
echo -e $LDIF_ORG> /tmp/ldif_org.ldif
LDIF_PERSON="dn: cn=$1,o=$2,dc=certification,dc=com\nobjectClass: inetOrgPerson\nobjectClass: organizationalPerson\nobjectClass: person\nobjectClass: top\ncn: $1\ndescription: TEST CERTIFICATE\nmail: $3\no: $2\nsn: $SERIAL\nuserCertificate;binary:< file://$PATHCLIENT/$NAMEFILE.der\nuserPassword: $CLIENT_LDAP_PASSWORD"
echo -e $LDIF_PERSON> /tmp/ldif_person.ldif
#ldapadd -x -D "cn=Manager,dc=certification,dc=com" -W -f /tmp/ldif_org.ldif
ldapadd -x -D "cn=Manager,dc=certification,dc=com" -W -f /tmp/ldif_person.ldif
