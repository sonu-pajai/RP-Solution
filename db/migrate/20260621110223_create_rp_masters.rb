class CreateRpMasters < ActiveRecord::Migration[8.0]
  def change
    create_table :rp_masters do |t|
      t.string :unique_code
      t.string :salutation
      t.string :name
      t.string :category
      t.string :specific_relationship
      t.string :related_to_director
      t.date :dob_or_incorporation
      t.references :reporting_entity, null: false, foreign_key: true
      t.references :period, null: false, foreign_key: true

      t.timestamps
    end
  end
end
