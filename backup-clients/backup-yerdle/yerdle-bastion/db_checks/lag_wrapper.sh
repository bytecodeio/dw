#!/bin/bash
RUBY_VERSION=ruby-2.2.1
GEM_HOME=/usr/local/rvm/gems/ruby-2.2.1
GEM_PATH=/usr/local/rvm/gems/ruby-2.2.1:/usr/local/rvm/gems/ruby-2.2.1@global
PATH=/usr/local/rvm/gems/ruby-2.2.1/bin:/usr/local/rvm/gems/ruby-2.2.1@global/bin:/usr/local/rvm/rubies/ruby-2.2.1/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/usr/local/rvm/bin:/root/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.2.1

cd /root/db_checks
config="./config/postgres_config.rb"
results=`./check_postgres_lag.sh --config_file_path=$config --lag_threshold="60"`
echo "${results}"
lag_time=`echo "${results}" | awk 'NR==3' | awk '{print $3}'`
exit_code=`echo "${results}" | awk 'NR==4' | awk '{print $1}'`
if [ $exit_code -eq 1 ]; then
  curl -X POST -H 'Content-type: application/json' --data '{"text":"Please check postgres lag, currently '${lag_time}'s behind master"}' https://hooks.slack.com/services/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
fi


