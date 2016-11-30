
class GrowthMomWorksheet < KeyMetricsWorksheet

  def initialize(spreadsheet, key)

    puts "\nInitializing GrowthMomWorksheet\n\n"

    @first_summary_column_value = "MoM"

    super(spreadsheet, key, "WIP - Growth Monthly")

    # overrides
    @date_key = :month
  end

end
