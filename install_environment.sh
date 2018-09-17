#/bin/bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install percona-server
brew services start percona-server
brew install dnsmasq
echo 'conf-dir=/usr/local/etc/dnsmasq.d/,*.conf' >> /usr/local/etc/dnsmasq.conf
cd /usr/local/etc/dnsmasq.d/ && curl -O https://raw.githubusercontent.com/Nokors/dnsmasq/master/test.conf
sudo brew services start dnsmasq
sudo mkdir -p /etc/resolver/
sudo echo 'nameserver 127.0.0.1' > /etc/resolver/test

read -p 'Username: ' uservar
read -p 'User group: ' usergroupvar
PHP_FPM_CONFIG_FOLDER='/usr/local/etc/php/7.1/php-fpm.d/';
PHP_FPM_FOLDER='/usr/local/etc/php/7.1/';
echo '----Remove defalt php-fpm  settings----' 
sudo rm -f $PHP_FPM_FOLDER'www.conf.default'
echo '----Install new php-fpm pool settings----' 

cd $PHP_FPM_CONFIG_FOLDER && sudo curl -O https://raw.githubusercontent.com/Nokors/php-fpm/master/php-fpm-71.conf
sudo find $PHP_FPM_CONFIG_FOLDER'*.conf' -type f | while read fname; do
	sudo sed -i -e "s/www-data-user/$uservar/g" {} \;
	sudo sed -i -e "s/www-data-group/$usergroupvar/g"
done;

echo '----Completed----'
echo '----Drop default php-fpm config settings----'
sudo rm -f /etc/php-fpm.conf.default
echo '----Install new php-fpm config file----'
PHP_FPM_FOLDER
cd /etc/ && sudo curl -O https://raw.githubusercontent.com/Nokors/php-fpm/master/php-fpm.conf
PHP_FPM_CONFIG_DEFAULT_FILE='/usr/local/etc/php/7.1/php-fpm.conf';
sudo find $PHP_FPM_CONFIG_DEFAULT_FILE -type f | while read fname; do
	sudo sed -i -e "s/www-data-user/$uservar/g" {} \;
	sudo sed -i -e "s/www-data-group/$usergroupvar/g"
done;
echo '----Completed----'
echo '----Run PHP-FPM service as daemon ----'
sudo mkdir -p /var/log/php-fpm/ && echo '' > /var/log/php-fpm.log && sudo chmod og+rw /var/log/php-fpm.log && sudo php-fpm --fpm-config /etc/php-fpm.conf -D
echo '----Complete PHP-FPM start ----' 


brew install nginx
cd /usr/local/etc/nginx/ && curl -O https://raw.githubusercontent.com/Nokors/nginx/master/nginx.conf
mkdir -p /usr/local/etc/nginx/sites-enabled/ /usr/local/etc/nginx/conf.d/
cd /usr/local/etc/nginx/conf.d/ && curl -O https://raw.githubusercontent.com/Nokors/nginx/master/conf.d/php71.conf
echo '----Drop default php-fpm pool settings----'
NGINX_CONFIG='/usr/local/etc/nginx';
cd $NGINX_CONFIG && sudo curl -O https://raw.githubusercontent.com/Nokors/nginx/master/nginx.conf
sudo find $NGINX_CONFIG -name 'nginx.conf' | while read fname; do
	sudo sed -i -e "s/www-data-user/$uservar/g" $fname;
	sudo sed -i -e "s/www-data-group/$usergroupvar/g" $fname;
done;
sudo mkdir /var/log/nginx/ && sudo chmod go+wx /var/log/nginx/
sudo brew services start nginx
