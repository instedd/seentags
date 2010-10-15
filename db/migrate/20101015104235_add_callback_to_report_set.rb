class AddCallbackToReportSet < ActiveRecord::Migration
  def self.up
    add_column :report_sets, :url_callback, :string
  end

  def self.down
    remove_column :report_sets, :url_callback
  end
end
