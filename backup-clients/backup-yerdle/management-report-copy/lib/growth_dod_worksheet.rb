
class GrowthDodWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing GrowthDodWorksheet\n\n"

    @first_summary_column_value = "DoD"

    super(spreadsheet, key, "WIP - Growth Daily")
  end

end
