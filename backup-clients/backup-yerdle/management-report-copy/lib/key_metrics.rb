#  key_metrics.rb

require "google/api_client"
require "google_drive"
require 'sequel'
require 'configatron'

require './config/config'
require 'sql_job'
require 'key_metrics_worksheet'
require 'mom_worksheet'
require 'mtd_worksheet'
require 'wow_worksheet'
require 'daily_worksheet'
require 'growth_dod_worksheet'
require 'growth_mom_worksheet'

# include Redshift

class KeyMetrics

  def initialize
    @session = GoogleDrive.login_with_oauth(get_access_token)
    @spreadsheet_key = configatron.spreadsheets.key
    @spreadsheet = @session.spreadsheet_by_key(@spreadsheet_key)
  end

  def update_source_column(worksheet_key)
    ws = KeyMetricsWorksheet.create(@spreadsheet, worksheet_key)
    ws.update_source_column
  end

  # main method for running sql in a single worksheet
  def sheet_runner(worksheet_key, dump=false, overwrite=false, source=nil, run_before=nil)
    ws = KeyMetricsWorksheet.create(@spreadsheet, worksheet_key)
    if source.nil?
      puts "Runnig the entire worksheet. Get the list of reports first."
      sql_base_list = ws.run_sql(source, overwrite, dump, run_before) unless !ws.validate
      return sql_base_list # return this to metricks
    else
      ws.run_sql(source, overwrite, dump, run_before) unless !ws.validate
    end
  end

  # Walk sheet
  def sheet_walker(worksheet_key)
    ws = KeyMetricsWorksheet.create(@spreadsheet, worksheet_key)
    ws.walk unless !ws.validate
  end

  private

  def get_access_token
    client = Google::APIClient.new(application_name: 'key-metrics', application_version: '0.0.1')
    key = Google::APIClient::KeyUtils.load_from_pkcs12(
      File.join('./config/', configatron.google.keyfile_name),
      configatron.google.password
    )

    asserter = Google::APIClient::JWTAsserter.new(
      configatron.google.service_account_email,
      ['https://www.googleapis.com/auth/drive'],
      key
    )

    client.authorization = asserter.authorize
    client.authorization.access_token
  end
end


