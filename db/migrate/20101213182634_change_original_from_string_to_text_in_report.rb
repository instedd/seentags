class ChangeOriginalFromStringToTextInReport < ActiveRecord::Migration
  def self.up
    change_column :reports, :original, :text
  end

  def self.down
    change_column :reports, :original, :string
  end
end
