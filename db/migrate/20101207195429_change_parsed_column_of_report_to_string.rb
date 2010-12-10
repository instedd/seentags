class ChangeParsedColumnOfReportToString < ActiveRecord::Migration
  def self.up
    change_column :reports, :parsed, :text
  end

  def self.down
    change_column :reports, :parsed, :string
  end
end
