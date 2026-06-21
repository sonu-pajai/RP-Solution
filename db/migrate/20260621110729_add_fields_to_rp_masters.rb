class AddFieldsToRpMasters < ActiveRecord::Migration[8.0]
  def change
    add_column :rp_masters, :pan, :string
    add_column :rp_masters, :related_party_sebi, :boolean
    add_column :rp_masters, :related_party_companies_act, :boolean
    add_column :rp_masters, :related_party_as18, :boolean
    add_column :rp_masters, :related_party_ind_as24, :boolean
    add_column :rp_masters, :other_guidelines, :string
    add_column :rp_masters, :active, :boolean
    add_column :rp_masters, :created_by, :string
    add_column :rp_masters, :approved_by, :string
    add_column :rp_masters, :admin_approved, :string
  end
end
