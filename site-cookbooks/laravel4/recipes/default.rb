#
# Cookbook Name:: laravel4
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
# Cookbook Name:: the-rankers
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

link "/usr/local/webapp" do
  to "/vagrant/webapp"
end

# Stopping iptables
service 'iptables' do
  action [:disable, :stop]
end

execute "adding epel repository" do
  command "sudo rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm"
  action :run
  not_if "sudo yum repolist all | grep epel"
end

execute "adding remi repository" do
  command "sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm"
  action :run
  not_if "sudo yum repolist all | grep remi"
end

#execute "updating yum" do
#  user "root"
#  command "sudo yum -y update"
#  action :run
#end

%w{git wget curl unzip}.each do |pkg|
  execute "installing #{pkg}" do
    user "root"
    command "sudo yum -y install #{pkg}"
    action :run
  end
end

execute "installing redis" do
  user "root"
  command "sudo yum -y install redis --enablerepo=remi"
  action :run
end

service "redis" do
  action [:enable, :start]
end

execute "installing memcached" do
  user "root"
  command "sudo yum -y install memcached --enablerepo=remi"
  action :run
end

service "memcached" do
  action [:enable, :start]
end

execute "installing mysql" do
  user "root"
  command "sudo yum -y install mysql mysql-server --enablerepo=remi"
  action :run
end

service "mysqld" do
  action [:enable, :start]
end

execute "installing php" do
  user "root"
  command "sudo yum -y install php php-cli php-pdo php-mbstring php-mcrypt php-mysql php-devel php-common php-pgsql php-pear php-xml php-pecl-xdebug php-pecl-apc php-redis php-fpm --enablerepo=remi-php55"
  action :run
end

execute "installing nginx" do
  user "root"
  command "sudo yum -y install nginx --enablerepo=remi"
  action :run
end

service "nginx" do
  action [:enable, :start]
end

service "php-fpm" do
  action [:enable, :start]
end

file "/etc/nginx/conf.d/default.conf" do
  action :delete
  notifies :restart, "service[nginx]"
end

template "/etc/nginx/conf.d/laravel4.conf" do
  mode 0644
  source "laravel4.conf.erb"
  notifies :restart, "service[nginx]"
end

# installing phpMyAdmin
remote_file "#{Chef::Config[:file_cache_path]}/phpMyAdmin-#{node.phpmyadmin.version}-all-languages.zip" do
  source "http://file.yucchiy.com/public/phpMyAdmin-#{node.phpmyadmin.version}-all-languages.zip"
  action :create
  not_if { ::File.exists?("phpMyAdmin-#{node.phpmyadmin.version}-all-languages.zip") }
end

bash "install phpmyadmin" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  unzip ./phpMyAdmin-#{node.phpmyadmin.version}-all-languages.zip
  mkdir -p #{node.phpmyadmin.document_root}
  cp -rp phpMyAdmin-#{node.phpmyadmin.version}-all-languages/* #{node.phpmyadmin.document_root}
  chown -R vagrant:vagrant #{node.phpmyadmin.document_root}
  EOH
  not_if { ::Dir.exists?(node.phpmyadmin.document_root) }
end

template "#{node.phpmyadmin.document_root}/config.inc.php" do
  mode 0644
  source "phpmyadmin-config.inc.php.erb"
end

template "/etc/nginx/conf.d/phpmyadmin.conf" do
  mode 0644
  source "phpmyadmin.conf.erb"
  notifies :restart, "service[nginx]"
end

bash "installing composer" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  sudo curl -sS https://getcomposer.org/installer | sudo php
  sudo mv composer.phar /usr/local/bin/composer
  EOH
  not_if { ::File.exists?("/usr/local/bin/composer") }
end

template "/etc/profile.d/composer.sh" do
  mode 0644
  source "profile.d-composer.sh"
end

bash "install phpunit" do
  user "vagrant"
  code <<-EOH
  sudo -u vagrant /usr/local/bin/composer global require 'phpunit/phpunit=3.7.*'
  EOH
  not_if { ::File.exists?("/~/.composer/vendor/bin/phpunit") }
end

