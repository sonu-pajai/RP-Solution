class FixRpMastersFields < ActiveRecord::Migration[8.0]
  def change
    remove_column :rp_masters, :related_to_director, :string
    add_column :rp_masters, :related_to_director, :boolean, default: false

    remove_column :rp_masters, :created_by, :string
    remove_column :rp_masters, :approved_by, :string
    remove_column :rp_masters, :admin_approved, :string

    add_reference :rp_masters, :created_by, foreign_key: { to_table: :users }, null: true
    add_reference :rp_masters, :approved_by, foreign_key: { to_table: :users }, null: true
    add_reference :rp_masters, :admin_approved_by, foreign_key: { to_table: :users }, null: true
  end
end
