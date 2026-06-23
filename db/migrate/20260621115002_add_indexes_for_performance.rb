class AddIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    # rp_transactions: composite index for upsert matching
    add_index :rp_transactions, [:reporting_entity_id, :reporting_unit_id, :period_id, :counterparty, :nature, :sub_nature, :transaction_type], name: "idx_rp_transactions_upsert_match"

    # rp_masters: search and filter
    add_index :rp_masters, :unique_code
    add_index :rp_masters, :name
    add_index :rp_masters, :category
    add_index :rp_masters, :active

    # rp_consolidations: composite for find_or_initialize_by
    add_index :rp_consolidations, [:rp_master_id, :reporting_entity_id, :period_id], name: "idx_rp_consolidations_composite"

    # transactions master: cascading dropdown queries
    add_index :transactions, :nature
    add_index :transactions, [:nature, :sub_type], name: "idx_transactions_nature_sub_type"

    # periods
    add_index :periods, :month

    # reporting_entities
    add_index :reporting_entities, :name, unique: true
  end
end
