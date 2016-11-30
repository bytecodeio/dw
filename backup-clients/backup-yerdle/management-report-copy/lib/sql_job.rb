
#  connect to Redshift
HOST = configatron.db.host
PORT = configatron.db.port
DATABASE = configatron.db.database
USERNAME = configatron.db.user
PASSWORD = configatron.db.password

OPTIONS = {
  client_min_messages: false,
  force_standard_strings: false,
  connect_timeout: 600,
  max_connections:2,
  pool_sleep_time:0.1,
  pool_timeout:30
}

DB = Sequel.connect("postgres://#{USERNAME}:#{PASSWORD}@#{HOST}:#{PORT}/#{DATABASE}", OPTIONS)

class SqlJob

  def initialize(sql_subdir, sql_base)
    @fullpath = File.join(Dir.pwd, 'sql', 'spreadsheet', sql_subdir, sql_base) + ".sql"
    puts "fullpath: #{@fullpath}"

    raise "#{@fullpath} does not exist." unless File.exist?(@fullpath)
  end

  def run

    sql = File.read(@fullpath)

    puts "\n#{sql}\n"

    DB.fetch(sql) do |row|
      yield row
    end
  end

  def self.test_query
    sql = %Q{
      select 'implement a test query'
    }

    DB.fetch(sql) do |row|
      puts "  #{row[:host]} #{row[:event_type]}"
    end
  end

end
