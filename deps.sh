#!/bin/sh

rm -rf puppet/modules/*

# common
git clone git://github.com/puppetlabs/puppetlabs-stdlib.git puppet/modules/stdlib
git clone https://github.com/puppetlabs/puppetlabs-apt puppet/modules/apt


# mysql
git clone https://github.com/puppetlabs/puppetlabs-mysql.git puppet/modules/mysql
