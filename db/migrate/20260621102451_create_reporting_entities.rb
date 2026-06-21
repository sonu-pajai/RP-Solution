class CreateReportingEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :reporting_entities do |t|
      t.string :name

      t.timestamps
    end
  end
end
