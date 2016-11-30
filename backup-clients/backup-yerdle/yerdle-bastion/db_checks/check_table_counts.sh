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

  desc "check", "Check count difference between 2 databases"
  method_option :config_file_path_1, :type => :string, :required => true,
    :desc => "File path of the config file that contains credentials in connecting to the first database"
  method_option :config_file_path_2, :type => :string, :required => true,
    :desc => "File path of the config file that contains credentials in connecting to the second database"
  method_option :table_name_1, :type => :string, :required => true,
    :desc => "Name of the first table to count"
  method_option :table_name_2, :type => :string, :required => true,
    :desc => "Name of the second table to count"
  method_option :diff_threshold, :type => :numeric, :required => true,
    :desc => "Percentage difference between the tables"

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
    puts 'Checking difference with threshold: ' + options[:diff_threshold].to_s + '%'
    #  connect to DB 1
    require options['config_file_path_1']
    self.class.HOST = configatron.db.host
    self.class.PORT = configatron.db.port
    self.class.DATABASE = configatron.db.database
    self.class.USERNAME = configatron.db.user
    self.class.PASSWORD = configatron.db.password
    table_name = options[:table_name_1]
    query = 'select * from ' + table_name

    db_1 = Sequel.connect("postgres://#{self.class.USERNAME}:#{self.class.PASSWORD}@#{self.class.HOST}:#{self.class.PORT}/#{self.class.DATABASE}", OPTIONS)
    db1_dataset = db_1[query]
    r_count = db1_dataset.count

    puts 'DB 1 '+ table_name +' table total count: ' + r_count.to_s
    configatron.reset!

    #  connect to DB 2
    require options['config_file_path_2']
    self.class.HOST = configatron.db.host
    self.class.PORT = configatron.db.port
    self.class.DATABASE = configatron.db.database
    self.class.USERNAME = configatron.db.user
    self.class.PASSWORD = configatron.db.password
    table_name = options[:table_name_2]
    query = 'select * from ' + table_name

    db_2 = Sequel.connect("postgres://#{self.class.USERNAME}:#{self.class.PASSWORD}@#{self.class.HOST}:#{self.class.PORT}/#{self.class.DATABASE}", OPTIONS)
    db2_dataset = db_2[query]
    p_count = db2_dataset.count

    puts 'DB 2 '+ table_name +' table total count: ' + p_count.to_s

    percent_threshold = 0
    if p_count > r_count
      percent_threshold = 100 - r_count.to_f / p_count * 100
    elsif p_count < r_count
      percent_threshold = 100 - p_count.to_f / r_count * 100
    end

    puts 'Percent difference is: ' + percent_threshold.to_s + '%'

    if percent_threshold > options[:diff_threshold]
      puts 1
      return 1
    else
      puts 0
      return 0
    end

  end
  default_task :check
end

CheckTableCount.start
