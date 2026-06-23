class RemoveCategoryFromRpConsolidations < ActiveRecord::Migration[8.0]
  def change
    remove_column :rp_consolidations, :category, :string
  end
end
