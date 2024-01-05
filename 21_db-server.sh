#!/bin/bash
sudo docker run --name db1 -d --rm -p 1521:80 -v ./html:/usr/share/nginx/html nginx
sudo docker run --name db2 -d --rm -p 3306:80 -v ./html:/usr/share/nginx/html nginx
