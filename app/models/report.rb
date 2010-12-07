class Report < ActiveRecord::Base
  belongs_to :report_set

  validates_presence_of :original, :report_set

  # Parsed all given Reports and returns them in an array.
  # If a block is given it must contains two arguments,
  # the first one is the original report and the second one
  # is a parse of it. This allows modifying each parse.
  def self.parse_all(reports)
    parsed = []
    reports.each do |report|
      reps = Parser.new(report.parsed || report.original).parse
      reps.each do |rep|
        yield report, rep if block_given?
        parsed << rep
      end
    end
    parsed
  end
end
