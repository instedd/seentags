class AddSubmitUrlKeyToReportSets < ActiveRecord::Migration
  def self.up
    add_column :report_sets, :submit_url_key, :string
  end

  def self.down
    remove_column :report_sets, :submit_url_key
  end
end
