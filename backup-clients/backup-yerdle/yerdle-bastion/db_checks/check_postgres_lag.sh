#!/usr/bin/env ruby

# == check_table_counts
# Checks the count difference from 2 different tables in 2 different databases
# depending on a percent threshold
# Returns(prints) 1 if percent difference is higher than the threshold
# Returns(prints) 0 if percent difference is lower than the threshold

require "rubygems"
require "bundler/setup"
require "date"
require "json"
require "thor"
require "sequel"
require "configatron"

#
#
# == Summary
# Checks the count difference from 2 different tables in 2 different databases
# depending on a percent threshold
# Returns(prints) 1 if percent difference is higher than the threshold
# Returns(prints) 0 if percent difference is lower than the threshold
# == Example
# <tt>./check_table_counts.sh --config-file-path-1=./config1.rb --config-file-path-2=./config2.rb --table-name-1=users --table-name-2=users --diff-threshold=7
# 

class CheckTableCount < Thor

  desc "check", "Check if replica is lagging behind master"
  method_option :config_file_path, :type => :string, :required => true,
    :desc => "File path of the config file that contains credentials in connecting to the database"
  method_option :lag_threshold, :type => :numeric, :required => true,
    :desc => "Acceptable level of lag for the replica"

  OPTIONS = {
    client_min_messages: false,
    force_standard_strings: false,
    connect_timeout: 600,
    max_connections:2,
    pool_sleep_time:0.1,
    pool_timeout:30
  }

  class << self
    attr_accessor :HOST
    attr_accessor :PORT
    attr_accessor :DATABASE
    attr_accessor :USERNAME
    attr_accessor :PASSWORD
  end

  def check
    puts 'Checking lag with threshold: ' + options[:lag_threshold].to_s
    #  connect to DB 1
    require options['config_file_path']
    self.class.HOST = configatron.db.host
    self.class.PORT = configatron.db.port
    self.class.DATABASE = configatron.db.database
    self.class.USERNAME = configatron.db.user
    self.class.PASSWORD = configatron.db.password
    table_name = options[:table_name_1]
    query = 'SELECT EXTRACT(EPOCH FROM (now() - pg_last_xact_replay_timestamp()))::INT/60 as mins_behind'

    db_1 = Sequel.connect("postgres://#{self.class.USERNAME}:#{self.class.PASSWORD}@#{self.class.HOST}:#{self.class.PORT}/#{self.class.DATABASE}", OPTIONS)
    db1_dataset = db_1[query]
    puts db1_dataset
    s_lag = db1_dataset.get(:mins_behind)

    puts 'Server is ' + s_lag.to_s + ' behind master.'
    configatron.reset!

    if s_lag >= options[:lag_threshold]
      puts s_lag
      return s_lag
    else
      puts 0
      return 0
    end

  end
  default_task :check
end

CheckTableCount.start
