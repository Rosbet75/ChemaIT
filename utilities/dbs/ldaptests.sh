#!/bin/bash

LDAP_ADMIN="cn=admin,dc=nteum,dc=local"
LDAP_PASS="eneto"
LDAP_URI="ldap://localhost:389"
BASE_DN="dc=nteum,dc=local"
OU_PEOPLE="ou=People,$BASE_DN"

# Función para crear un usuario LDAP
# Parámetros: $1=uid, $2=nombre completo, $3=apellido, $4=email, $5=password (plain)
crear_usuario () {
  UID="$1"
  CN="$2"
  SN="$3"
  MAIL="$4"
  PASS="$5"

  # Convertir password a hash SSHA para LDAP
  PASS_HASH=$(slappasswd -s "$PASS")

  # Crear contenido LDIF
  LDIF_CONTENT="
dn: uid=$UID,$OU_PEOPLE
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: $CN
sn: $SN
uid: $UID
mail: $MAIL
uidNumber: $(shuf -i 10000-20000 -n 1)
gidNumber: 500
homeDirectory: /home/$UID
loginShell: /bin/bash
userPassword: $PASS_HASH
"

  # Añadir usuario LDAP
  echo "$LDIF_CONTENT" | ldapadd -x -D "$LDAP_ADMIN" -w "$LDAP_PASS" -H "$LDAP_URI"
}

# Crear la unidad organizativa People si no existe
echo "
dn: ou=People,$BASE_DN
objectClass: organizationalUnit
ou: People
" | ldapadd -x -D "$LDAP_ADMIN" -w "$LDAP_PASS" -H "$LDAP_URI" || echo "OU People ya existe"

# Ejemplo de creación de usuarios
crear_usuario "jdoe" "John Doe" "Doe" "jdoe@nteum.local" "password123"
crear_usuario "asmith" "Alice Smith" "Smith" "asmith@nteum.local" "passw0rd"
