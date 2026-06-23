class ChangeRelatedToDirectorToString < ActiveRecord::Migration[7.1]
  def change
    change_column :rp_masters, :related_to_director, :string
  end
end
