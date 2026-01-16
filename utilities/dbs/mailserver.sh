docker exec -it mailserver setup email add usuario@nteum.com eneto123
docker exec -it mailserver setup email add usuario2@nteum.com eneto123
docker exec -it mailserver setup email add usuari3@nteum.com eneto123



docker exec -i acceso-unico ldapadd -x -D "cn=admin,dc=nteum,dc=local" -w eneto <<EOF
dn: uid=usuario1,dc=nteum,dc=local
objectClass: inetOrgPerson
cn: Usuario Uno
sn: Uno
uid: usuario1
userPassword: eneto123
EOF


docker exec -i acceso-unico ldapadd -x -D "cn=admin,dc=nteum,dc=local" -w eneto <<EOF
dn: uid=usuario2,dc=nteum,dc=local
objectClass: inetOrgPerson
cn: Usuario Dos
sn: Dos
uid: usuario2
userPassword: eneto123
EOF


docker exec -i acceso-unico ldapadd -x -D "cn=admin,dc=nteum,dc=local" -w eneto <<EOF
dn: uid=usuario3,dc=nteum,dc=local
objectClass: inetOrgPerson
cn: Usuario Tres
sn: Tres
uid: usuario3
userPassword: eneto123
EOF


echo -e "eneto123\neneto123" | docker exec -i datos-compartidos-windows smbpasswd -a -s usuario1
echo -e "eneto123\neneto123" | docker exec -i datos-compartidos-windows smbpasswd -a -s usuario2
echo -e "eneto123\neneto123" | docker exec -i datos-compartidos-windows smbpasswd -a -s usuario3


docker exec -it impresion-red lpadmin -p Impresora1 -E -v socket://192.168.1.101 -m everywhere
docker exec -it impresion-red cupsenable Impresora1

docker exec -it impresion-red lpadmin -p Impresora2 -E -v socket://192.168.1.102 -m everywhere
docker exec -it impresion-red cupsenable Impresora2

docker exec -it impresion-red lpadmin -p Impresora3 -E -v socket://192.168.1.103 -m everywhere
docker exec -it impresion-red cupsenable Impresora3


docker exec -it servidor-ftp bash -c "adduser --disabled-password --gecos '' usuario1 && echo 'usuario1:eneto123' | chpasswd"
docker exec -it servidor-ftp bash -c "adduser --disabled-password --gecos '' usuario2 && echo 'usuario2:eneto123' | chpasswd"
docker exec -it servidor-ftp bash -c "adduser --disabled-password --gecos '' usuario3 && echo 'usuario3:eneto123' | chpasswd"

docker exec -i base-datos mysql -uroot -peneto -e "CREATE DATABASE usuario4_db; CREATE USER 'usuario4'@'%' IDENTIFIED BY 'eneto123'; GRANT ALL PRIVILEGES ON usuario4_db.* TO 'usuario4'@'%'; FLUSH PRIVILEGES;"
docker exec -i base-datos mysql -uroot -peneto -e "CREATE DATABASE usuario5_db; CREATE USER 'usuario5'@'%' IDENTIFIED BY 'eneto123'; GRANT ALL PRIVILEGES ON usuario5_db.* TO 'usuario5'@'%'; FLUSH PRIVILEGES;"
docker exec -i base-datos mysql -uroot -peneto -e "CREATE DATABASE usuario6_db; CREATE USER 'usuario6'@'%' IDENTIFIED BY 'eneto123'; GRANT ALL PRIVILEGES ON usuario6_db.* TO 'usuario6'@'%'; FLUSH PRIVILEGES;"
