Warning: this image is wip, it might not works yet


* You must create database schema manually

To start a magma instance:
```shell
docker run --name my-magma --link mysql:mysql --link memcache:memcache -e MYSQL_HOST=mysql -e MYSQL_USER=root -e MYSQL_PASSWORD=root -e MYSQL_SCHEMA=magma magma
```

LINK:
 - a mysql/mariadb container linked
 - a memached container linked with name memache

VOLUME:
- /magma

ENV:
- MYSQL_HOST=mysql
- MYSQL_USER=root
- MYSQL_PASSWORD=root
- MYSQL_SCHEMA=magma

EXPOSE:
- various ports, not configured yet
