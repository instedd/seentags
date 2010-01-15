class AddCorrectedToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :corrected, :boolean, :default => 1
  end

  def self.down
    remove_column :reports, :corrected
  end
end
