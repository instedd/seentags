class FillSubmitUrlKeyForEmpty < ActiveRecord::Migration
  def self.up
    ReportSet.all(:conditions => ["submit_url_key = ''"]).each do |report|
      report.generate_submit_url_key
      report.save!
    end
  end

  def self.down
  end
end
