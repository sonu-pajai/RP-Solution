class CreateReportingUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :reporting_units do |t|
      t.string :name
      t.references :reporting_entity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
