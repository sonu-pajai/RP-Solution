class AddIndexesToRpMasters < ActiveRecord::Migration[7.0]
  def change
    add_index :rp_masters, :unique_code, if_not_exists: true
    add_index :rp_masters, :name, if_not_exists: true
    add_index :rp_masters, :pan, if_not_exists: true
    add_index :rp_masters, :category, if_not_exists: true
    add_index :rp_masters, :specific_relationship, if_not_exists: true
    add_index :rp_masters, :active, if_not_exists: true
    add_index :rp_masters, :related_party_sebi, if_not_exists: true
    add_index :rp_masters, :related_party_companies_act, if_not_exists: true
    add_index :rp_masters, :approved_by_id, if_not_exists: true

    add_index :rp_consolidations, [:rp_master_id, :reporting_entity_id, :period_id], name: "idx_rp_consolidations_master_entity_period", if_not_exists: true
    add_index :rp_consolidations, :period_id, if_not_exists: true
    add_index :rp_consolidations, :reporting_entity_id, if_not_exists: true
  end
end
