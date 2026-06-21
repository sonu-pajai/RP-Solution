class AddCategoryToRelationships < ActiveRecord::Migration[8.0]
  def change
    add_column :relationships, :category, :string
  end
end
