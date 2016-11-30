#!/bin/bash
RUBY_VERSION=ruby-2.2.1
GEM_HOME=/usr/local/rvm/gems/ruby-2.2.1
GEM_PATH=/usr/local/rvm/gems/ruby-2.2.1:/usr/local/rvm/gems/ruby-2.2.1@global
PATH=/usr/local/rvm/gems/ruby-2.2.1/bin:/usr/local/rvm/gems/ruby-2.2.1@global/bin:/usr/local/rvm/rubies/ruby-2.2.1/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/usr/local/rvm/bin:/root/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.2.1

cd /root/management-report

date --rfc-3339=ns
./management-report runner -w daily

date --rfc-3339=ns
# Overwrite fullfillment because it's 10 day rolling. post claims also.
./management-report runner -o -w daily -s fulfillment_items fulfillment_ships fulfillment_pickups posts_claims_24_hrs posts_claims_28_days posts_claims_7_days

date --rfc-3339=ns
# Run Month to Date. Overwrite because it is a single column.
./management-report runner -o -w mtd

date --rfc-3339=ns
# Run Growth Daily. Overwrite because of the rolling time periods.
./management-report runner -o -w growth-dod
