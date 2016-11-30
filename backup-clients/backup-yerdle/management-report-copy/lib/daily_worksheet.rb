
class DailyWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing DailyWorksheet\n\n"

    @first_summary_column_value = "DoD"

    super(spreadsheet, key, "Daily")
  end

end
