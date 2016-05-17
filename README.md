## Notes:
- You must create database schema manually
- Container must run with `--privileged` flag in order to create secure mapped memory, else you must set magma.secure.memory.enable to false


## To start a magma instance:
```shell
docker run -d --name my-magma --privileged --link mysql:mysql --link memcache:memcache -e MYSQL_HOST=mysql -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e MYSQL_SCHEMA=magma magma
```

LINK:
 - a mysql/mariadb container linked
 - a memached container linked with name memache

VOLUME:
- /magma

ENV:
- DOMAIN=localhost.localdomain (your email domain)
- BASE_DIR=/magma (place your settings and data in other place, default is /magma
- MYSQL_HOST=mysql
- MYSQL_USER=root
- MYSQL_PASSWORD=root
- MYSQL_SCHEMA=magma

EXPOSE:
- SMTP: 25 465
- POP3: 110 995
- IMAP: 143 995
- HTTP 10000 10500
