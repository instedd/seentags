class RemoveOrphanReports < ActiveRecord::Migration
  def self.up
    Report.all.each do |report|
      if not report.report_set
        report.delete
      end
    end
  end

  def self.down
  end
end
