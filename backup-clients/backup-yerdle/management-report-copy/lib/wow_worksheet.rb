
class WowWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing WowWorksheet\n\n"

    @first_summary_column_value = "WoW"

    super(spreadsheet, key, "Weekly")
  end

end
