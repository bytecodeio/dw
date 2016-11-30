
class MtdWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing MtdWorksheet\n\n"

    @first_summary_column_value = "MtD"

    super(spreadsheet, key, "Month to Date")

    # overrides
    @date_key = :month
  end

end
