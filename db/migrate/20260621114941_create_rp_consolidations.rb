class CreateRpConsolidations < ActiveRecord::Migration[8.0]
  def change
    create_table :rp_consolidations do |t|
      t.references :rp_master, null: false, foreign_key: true
      t.references :reporting_entity, null: false, foreign_key: true
      t.references :period, null: false, foreign_key: true
      t.date :related_party_from
      t.date :related_party_upto
      t.string :custom_input

      t.timestamps
    end
  end
end
