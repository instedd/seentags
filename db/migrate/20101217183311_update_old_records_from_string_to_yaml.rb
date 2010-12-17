class UpdateOldRecordsFromStringToYaml < ActiveRecord::Migration
  def self.up
    Report.all.each do |report|
      if report.parsed and report.parsed.is_a? String
        report.parsed = Parser.parse(report.parsed).map &:to_s
        report.save
      end
    end
  end

  def self.down
  end
end
