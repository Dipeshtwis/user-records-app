class DailyRecordsController < ApplicationController
  def daily_records_report
    @daily_records = DailyRecord.all
  end
end
