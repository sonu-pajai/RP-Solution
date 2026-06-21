class AddRelationshipCategoryToRelationships < ActiveRecord::Migration[8.0]
  def change
    add_reference :relationships, :relationship_category, null: false, foreign_key: true
  end
end
