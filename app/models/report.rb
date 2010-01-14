class Report < ActiveRecord::Base
  belongs_to :report_set
  
  validates_presence_of :original, :parsed, :report_set
end
