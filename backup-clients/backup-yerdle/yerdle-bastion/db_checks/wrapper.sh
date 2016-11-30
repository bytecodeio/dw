#!/bin/bash
RUBY_VERSION=ruby-2.2.1
GEM_HOME=/usr/local/rvm/gems/ruby-2.2.1
GEM_PATH=/usr/local/rvm/gems/ruby-2.2.1:/usr/local/rvm/gems/ruby-2.2.1@global
PATH=/usr/local/rvm/gems/ruby-2.2.1/bin:/usr/local/rvm/gems/ruby-2.2.1@global/bin:/usr/local/rvm/rubies/ruby-2.2.1/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/aws/bin:/usr/local/rvm/bin:/root/bin

# load rvm ruby
source /usr/local/rvm/environments/ruby-2.2.1

cd /root/db_checks
config_1="./config/redshift_config.rb"
config_2="./config/postgres_config.rb"
cat table.list | while read p_table; do 
  results=`./check_table_counts.sh --config_file_path_1=$config_1 --config_file_path_2=$config_2 --table_name_1="yerdle_$p_table" --table_name_2="$p_table" --diff_threshold="5"`
  echo "${results}"
  perc_diff=`echo "${results}" | awk 'NR==4' | awk '{print $4}'`
  exit_code=`echo "${results}" | awk 'NR==5' | awk '{print $1}'`
  if [ $exit_code -eq 1 ]; then
# Comment out byte_yerdle channel. Send alerts to byte_bot channel instead.
#    curl -X POST -H 'Content-type: application/json' --data '{"text":"Please check counts for table '${p_table}', difference of '${perc_diff}'"}' https://hooks.slack.com/services/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
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Please check counts for table '${p_table}', difference of '${perc_diff}'"}' https://hooks.slack.com/services/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 
  fi
done


