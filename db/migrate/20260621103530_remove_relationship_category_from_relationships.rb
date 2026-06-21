class RemoveRelationshipCategoryFromRelationships < ActiveRecord::Migration[8.0]
  def change
    remove_reference :relationships, :relationship_category, foreign_key: true
  end
end
