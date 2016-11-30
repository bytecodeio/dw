#!/bin/bash
RUBY_VERSION=ruby-2.2.1
GEM_HOME=/usr/local/rvm/gems/ruby-2.2.1
GEM_PATH=/usr/local/rvm/gems/ruby-2.2.1:/usr/local/rvm/gems/ruby-2.2.1@global
PATH=/usr/local/rvm/gems/ruby-2.2.1/bin:/usr/local/rvm/gems/ruby-2.2.1@global/bin:/usr/local/rvm/rubies/ruby-2.2.1/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/usr/local/rvm/bin:/root/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.2.1

cd /root/management-report

./segment-report runner 

