class CreateReportDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :report_documents do |t|
      t.string :title
      t.text :content
      t.integer :reporting_entity_id
      t.integer :period_id
      t.integer :created_by_id

      t.timestamps
    end
  end
end
