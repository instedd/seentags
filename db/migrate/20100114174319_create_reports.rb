class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.integer :report_set_id
      t.string :original
      t.string :parsed

      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end
end
