#!/bin/bash
clear
echo "--------------***-------------"
echo "-----------WORDPRESS----------"
echo "[1] Cài đặt PHP-HTTPD-MYSQL-WORDPRESS"
echo "[2] Cấu hình MYSQL"
echo "[3] Cập nhật cấu hình MYSQL cho WORDPRESS"
echo "[4] Xoá toàn bộ cấu hình"
echo "Bạn muốn làm cái gì thì chọn đi:"
read number
if [ $number -eq 1 ]
then 
mkdir -p /web/www
mkdir /web/db
cd /web/www
touch info.php
echo -e "<?php\nphpinfo();\n?>" > info.php
touch index.html
echo "<center><h1>Nguyen Van Bien</h1></center>" > index.html
sysctl -w net.ipv4.ip_forward=1 
docker run -d --name p1 -h p1 -v /web/www/:/data php:8.1.4-fpm
docker exec p1 bash -c "docker-php-ext-install mysqli; docker-php-ext-install pdo_mysql"
docker run --rm -v /web/:/data httpd cp /usr/local/apache2/conf/httpd.conf /data
cd /web/
sed -i 's|#LoadModule proxy_module modules/mod_proxy.so|LoadModule proxy_module modules/mod_proxy.so|g' /web/httpd.conf
sed -i 's|#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so|LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so|g' /web/httpd.conf
sed -i 's|DocumentRoot "/usr/local/apache2/htdocs"|DocumentRoot "/data/"|g' /web/httpd.conf
sed -i 's|<Directory "/usr/local/apache2/htdocs">|<Directory "/data/">|g' /web/httpd.conf
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.html index.php index.htm/g' /web/httpd.conf
sed -i '551i Addhandler "proxy:fcgi://172.17.0.2:9000" .php' /web/httpd.conf
docker run -d --name h1 -h h1 -v /web/www/:/data/ -p 8080:80 -v /web/httpd.conf:/usr/local/apache2/conf/httpd.conf httpd
docker run -d --name m1 -h m1 -e MYSQL_ROOT_PASSWORD=123456 -v /web/db/:/data mysql
wget https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
cp -r wordpress/* /web/www/
cp /web/www/wp-config-sample.php /web/www/wp-config.php
docker restart p1 h1 m1
clear
echo "WORDPRESS ĐÃ CÀI ĐẶT XONG"
	elif [ $number -eq 2 ]
	then
		clear
		echo "-------CẤU HÌNH MYSQL-------"
		echo "[1] Xem DATABASE"
		echo "[2] Xem USER"
		echo "[3] Xem quyền USER"
		echo "[4] Tạo DATABASE"
		echo "[5] Tạo USER"
		echo "[6] Cấp quyền cho USER"
		echo "[7] Xoá DATABASE"
		echo "[8] Xoá USER"
		echo "[9] TRỞ LẠI MENU CHÍNH"
		echo "MUỐN LÀM GÌ THÌ CHỌN ĐI BẠN"
		read numb
	if [ $numb -eq 1 ]
		then
		 docker exec m1 bash -c "mysql -uroot -p123456 -e \"show databases;\"; exit;"
	elif [ $numb -eq 2 ]
		then 
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"select user from mysql.user;\"; exit;"
	elif [ $numb -eq 3 ]
		then
		echo "Bạn muốn xem quyền của user:"
		read user
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"show grants for '$user'@'%';\"; exit;"
	elif [ $numb -eq 4 ]
		then
		echo "Nhập tên database bạn muốn tạo: "
		read database
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"create database $database;\"; exit;"
	elif [ $numb -eq 5 ]
		then
		echo "Nhập tên user bạn muốn tạo: "
		read user1
		echo "Nhập password của user $user1: "
		read password
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"create user '$user1'@'%' identified by '$password';\"; exit;"
	elif [ $numb -eq 6 ]
		then
		echo "DATABASE bạn muốn cấp quyền: "
		read database1
		echo "USER mà bạn muốn cấp quyền cho DATABASE $database1: "
		read user2
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"grant all privileges on $database1.* to '$user2'@'%';\"; exit;"
	elif [ $numb -eq 7 ]
		then 
		echo "Nhập tên database bạn muốn xoá:"
		read database2
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"drop database $database2;\"; exit;"
	elif [ $numb -eq 8 ]
		then 
		echo "Nhập tên user bạn muốn xoá:"
		read user3
		docker exec m1 bash -c "mysql -uroot -p123456 -e \"drop user '$user3'@'%';\"; exit;"
	else [ $numb -eq 9 ]
			./wordpress.sh
	fi
	elif [ $number -eq 3 ]
		then
		echo "Nhập tên database:"
		read database3
		echo "Nhập tên user:"
		read user4
		echo "Nhập password của user $user4:"
		read password1
		echo "Nhập địa chỉ IP container MYSQL:"
		read ipadd
		sed -i "23d; 26d; 29d; 32d" /web/www/wp-config.php
		sed -i "23i define( 'DB_NAME', '$database3' );" /web/www/wp-config.php
		sed -i "26i define( 'DB_USER', '$user4' );" /web/www/wp-config.php
		sed -i "29i define( 'DB_PASSWORD', '$password1' );" /web/www/wp-config.php
		sed -i "29i define( 'DB_HOST', '$ipadd' );" /web/www/wp-config.php
	elif [ $number -eq 4 ]
		then
		docker rm -f p1 h1 m1
		rm -rf /web
fi
