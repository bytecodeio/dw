
class MomWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing MomWorksheet\n\n"

    @first_summary_column_value = "MoM"

    super(spreadsheet, key, "Monthly")

    # overrides
    @date_key = :month
  end

end
