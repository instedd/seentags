class CreateReportSets < ActiveRecord::Migration
  def self.up
    create_table :report_sets do |t|
      t.integer :account_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :report_sets
  end
end
