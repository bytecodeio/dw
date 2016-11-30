# key_metrics_worksheet.rb

require 'pry'
require 'pry-nav'

class KeyMetricsWorksheet

  HYPERLINK_OPENING = '=hyperlink('
  HYPERLINK_CLOSING = ')'
  URL_PREFIX = 'https://github.com/yerdle/management-report/tree/master/'
  # HYPERLINK_PREFIX_LENGTH = HYPERLINK_PREFIX.length
  PATH_PREFIX = 'sql/spreadsheet/'

  MAX_COLUMN_NUM = 1095

  LAST_UPDATED_FORMAT = "%Y-%m-%d %H:%M:%S"

  # factory method
  def self.create(spreadsheet, worksheet_key)

    key = worksheet_key.downcase

    case key
      when 'mom'
        MomWorksheet.new(spreadsheet, key)
      when 'mtd'
          MtdWorksheet.new(spreadsheet, key)
      when 'wow'
        WowWorksheet.new(spreadsheet, key)
      when 'revenue'
        RevenueWorksheet.new(spreadsheet, key)
      when 'daily'
        DailyWorksheet.new(spreadsheet, key)
      when 'growth-dod'
        GrowthDodWorksheet.new(spreadsheet, 'daily')
      when 'growth-mom'
        GrowthMomWorksheet.new(spreadsheet, 'mom')
      else
      raise "unknown worksheet key"
    end

  end

  def initialize(spreadsheet, key, title)

    @first_value_column = 8
    @last_updated_column = 3
    @date_key = :week

    @key = key
    @ws = spreadsheet.worksheet_by_title(title)  # a GoogleDrive::Worksheet

    raise "unable to instantiate worksheet" unless @ws
  end

  # method for running sql in a worksheet
  # see management-report for argument definitions
  def run_sql(source, overwrite, dump, run_before)
    puts "\nrunning SQL\n"
    puts "overwrite:[#{overwrite}] source: [#{source}]  run_before: [#{run_before}]  dump:[#{dump}]\n\n"

    # If we have to run the entire worksheet, simply grab the list of SQL reports to run
    # and return
    if source.nil?
      sql_base_list = Array.new
      iterate_rows(true) { | row, name, sql_base|
        sql_base_list.push(sql_base)
      }
      return sql_base_list
    end

    # TODO: implement dump
    raise "dump not implemented" if dump

    source_found = false
    iterate_rows(true) { |row, name, sql_base |
      #puts "row: #{row} name: #{name} sql_base: #{sql_base}"

      if source == sql_base
        source_found = true
        begin
          last_updated = DateTime.strptime(@ws[row, @last_updated_column], LAST_UPDATED_FORMAT)
        rescue ArgumentError => e
          last_updated = nil
        end

        # only walk the row if overwrite is on or the last updated date
        # for the row is earlier than the last column header's date
        if run_before.nil? || last_updated.nil? || last_updated < run_before
          row_walk(row, sql_base, overwrite)
        else
          puts "skipping row: #{row} name: #{name} sql_base: #{sql_base}"
        end
      end
    }
    # Should we raise an exception?
    # Perhaps not, since if we are running the entire worksheet, we don't want to halt
    # the entire program if one report is mis-spelt.
    if !source_found
      puts "Report not found: [#{source}]"
    end
  end

  # TODO: insert columns correctly

  # @ws[row,4]
  # walks a row of the spreadsheet
  # row - index of the row we are walking
  # overwrite - overwrite existing values
  def row_walk(row, sql_base, overwrite=false)
    t1 = Time.now
    puts "row=[#{row}] sql_base=[#{sql_base}] SQL start time=[" + t1.inspect + "]"
    start_sql = Time.now.to_i # time in epoch

    cur_col = @first_value_column

# pryed = false # DEBUGGING
    gotten_ahead_of_ourselves = false # for breaking outer loop

    # run the sql and then walk through the results,
    # moving through the columns and updating the value cells
    # where it matches the header (considering the overwrite setting)
    # NOTE we do not write incomplete weeks or months, ie where the
    # period represented is not yet complete
    # TODO: deal with formula rows here too
    job = SqlJob.new(@key, sql_base)

    print_flag = true
    job.run do |sql_result_row|

      # Capture timestamp for just the first row
      if print_flag
        t2 = Time.now
        puts "row [#{row}] sql_base=[#{sql_base}] SQL end time=[" + t2.inspect + "]"
        end_sql = Time.now.to_i # time in epoch
        runtime_sql = end_sql - start_sql
        puts "row [#{row}] sql_base=[#{sql_base}] SQL run time=[#{runtime_sql}] seconds"
      end
      print_flag = false


      date_hash_key = sql_result_row.keys[0]
      count_hash_key = sql_result_row.keys[1]
      sql_date = Date.strptime(sql_result_row[date_hash_key], "%Y-%m-%d")
# binding.pry unless pryed
# pryed = true

      # set the column position
      while cur_col < MAX_COLUMN_NUM
        cur_heading = @ws[1,cur_col]

        if cur_heading == @first_summary_column_value
          #puts " Setting GOTTEN_AHEAD_OF_OURSELVES cur_heading==FIRST_SUMMARY_COLUMN_VALUE"
          gotten_ahead_of_ourselves = true
          break
        end

        # this should handle blank column headings too
        begin
          heading_date = Date.strptime(cur_heading, "%Y-%m-%d")
        rescue ArgumentError
          raise "unexpected heading value (#{cur_heading}) in column #{cur_col}"
        end

        #puts "\tWHILE LOOP: \tcur_col #{cur_col} cur_heading #{cur_heading} heading_date #{heading_date} sql_date #{sql_date}"

       if heading_date <= sql_date
          #puts " heading_date <= sql_date IS TRUE - 1 \n"
          gotten_ahead_of_ourselves = true unless heading_date >= sql_date
          break
          #puts " heading_date <= sql_date IS TRUE - 2 \n"
       end

       cur_col += 1

      end
      # Write the value of gotten_ahead_of_ourselves
      #puts"\t\t After the WHILE look - GOTTEN_AHEAD_OF_OURSELVES = #{gotten_ahead_of_ourselves}"
      # write the value
      if heading_date == sql_date && ( @ws[row, cur_col] == '' || overwrite )
        puts "\twriting [#{sql_result_row[count_hash_key]}] to [#{cur_heading}]"
        @ws[row, cur_col] = sql_result_row[count_hash_key]
      end

      break if gotten_ahead_of_ourselves
    end
    @ws[row, @last_updated_column] = Time.now.strftime(LAST_UPDATED_FORMAT)
    @ws.save
  end

  # make sure all source columns in the sheet are unique
  # if a source value is passed in, make sure it exists and has the
  # auto column set to 'y'
  # TODO:
  def validate
    sql_bases = Array.new
    errors = 0

    iterate_rows { |row, name, sql_base |
      if !sql_base.nil? && sql_base != ''
        if sql_base != sql_base.downcase
          errors += 1
          puts "ERROR: sql filename '#{sql_base}' is not lowercase."
        elsif sql_bases.include?(sql_base)
          errors += 1
          puts "ERROR: sql filename '#{sql_base}' is not unique to sheet."
        end

      end

      # TODO - only allow lowercase in filenames

      sql_bases << sql_base
    }

    puts "there is a problem with your worksheet" unless errors == 0
    errors == 0
  end

  # walk the sheet and update the source column
  # used to add the hyperlinks and create SQL files
  def update_source_column

    section_title = nil

    for row in 2..@ws.num_rows
      col_A = @ws[row,1]

      if col_A != '' and !col_A.nil?
        section_title = col_A.downcase
      else
        col_D = @ws[row,4]

        # unless col_D.start_with?('=hyperlink') || col_D == '' || col_D.nil?
        unless col_D == '' || col_D.nil?

          raise 'invalid source name' unless col_D.end_with?('.sql')

          path = build_path(@key, col_D)
          content = build_content(path, col_D)

          puts "path:    #{path}"
          puts "content: #{content}"
          puts "sql:     #{sql_from_source_cell(content)}\n\n"

          FileUtils.touch(path) unless File.exist?(path)
          @ws[row,4] = content
        end
      end

      @ws.save
    end

  end

  # for debugging
  def walk
    iterate_rows(false) { |row, name, sql_base |
      puts "\trunning #{name} : #{sql_base}"
    }
  end

  private


  def iterate_rows(only_enabled=true)
    for row in 2..@ws.num_rows

      col_B = @ws[row,2]
      col_D = @ws[row,4].downcase
      col_E = @ws[row,5].downcase

      unless col_B.nil? || col_B == "" || (only_enabled && col_E != 'y')
        name = col_B
        sql_file = col_D
        sql_base = File.basename(sql_file, File.extname(sql_file))

        yield row, name, sql_base
      end

    end

  end

  # cheating here to make sure directory exists
  def build_path(dir, sql_filename)
    directory = File.join(PATH_PREFIX, dir)
    FileUtils.mkdir_p(directory) unless File.exist?(directory)
    File.join(directory, sql_filename)
  end

  def build_content(path, sql_filename)
    "#{HYPERLINK_OPENING}\"#{URL_PREFIX}#{path}\",\"#{sql_filename}\"#{HYPERLINK_CLOSING}"
  end

  # pulls the sql path out from a source cell content
  def sql_from_source_cell(content)
    tmp = content.sub(HYPERLINK_OPENING, '')
    tmp.sub!(URL_PREFIX, '')
    tmp.sub!(HYPERLINK_CLOSING, '')
    tmp.gsub!('"', '')
    sql = tmp.split(',')[0]
    sql
  end

  def calculate_next_col_date(starting_date)
    raise "calculate_next_col_date not implemented"
  end

end
