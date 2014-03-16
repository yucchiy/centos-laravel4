# CentOS64 Vagrant

A CentOS6.4 Vagrant setup with Laravel4, php5.5, nginx, php-fpm, and mysql.

## Requirements

* VirtualBox
* Vagrant **1.3+**
* Git

## Setup

* Clone this repository.
* run `vagrant up` inside the newly created directory.
  * the first time you run vagrant, it will take long time fetching the virtual box image.
* Vagrant uses chef to provision the base virtual box.
  * it could take a few minutes.
* You can verify by opening _http://192.168.23.10_ in a browser.

## Usage

Some basic information about the vagrant box.

**Todo: Writing!**

----

## Virtual Machine Specifications ##

* OS - CentOS 6.4 (Ja)
* nginx 1.0.15
* PHP 5.5.10
* MySQL 5.5.36
* Redis 2.8.7
* Memcached 1.4.15
