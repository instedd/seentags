ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/test_unit'
require File.expand_path(File.dirname(__FILE__) + "/blueprints")

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  def report(s)
    reps = Parser.new(s).parse
    assert_equal 1, reps.length
    reps.first
  end

  def reports(*rest)
    reps = []
    rest.each do |value|
      parsed_reports = Parser.new(value).parse
      reps.push *parsed_reports
    end
    reps
  end

  def assert_value(label, value, v)
    if label == "?"
      assert v.is_unlabelled?
    else
      assert_equal label, v.label
    end
    assert_equal value, v.value
  end

  def create_reports(report_set_id, *originals)
    reps = []
    originals.each do |original|
      reps << Report.create!(:report_set_id => report_set_id, :original => original)
    end
    reps
  end

  setup { Sham.reset }
end
