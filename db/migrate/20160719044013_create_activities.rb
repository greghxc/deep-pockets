class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :subject_id, null: false
      t.string :subject_type, null: false
      t.string :action, null: false
      t.string :context
      t.text :detail
      t.timestamps null: false
    end
  end
end
