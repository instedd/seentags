class Report < ActiveRecord::Base
  belongs_to :report_set

  validates_presence_of :original, :report_set

  serialize :parsed

  def self.parse_all(reports, &block)
    parsed = []
    reports.each do |report|
      report.parse.each do |parse|
        yield report, parse if block_given?
        parsed << parse
      end
    end
    parsed
  end

  def self.find_all_by_report_set_id(report_set_id)
    where("report_set_id = ?", report_set_id).all
  end

  def parse
    if self.parsed
      self.parsed = self.parsed.map!{|x| Parser.parse(x)}.flatten
    else
      self.parsed = Parser.parse(self.original)
    end
    self.parsed
  end
end
