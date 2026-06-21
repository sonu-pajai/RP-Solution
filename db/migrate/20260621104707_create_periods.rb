class CreatePeriods < ActiveRecord::Migration[8.0]
  def change
    create_table :periods do |t|
      t.string :month
      t.string :financial_year

      t.timestamps
    end
  end
end
