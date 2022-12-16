class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.string :user_id
      t.string :report, :length => 140
      t.timestamps
    end
  end
end
