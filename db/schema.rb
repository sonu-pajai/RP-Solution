# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_06_26_171826) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "periods", force: :cascade do |t|
    t.string "month"
    t.string "financial_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["month"], name: "index_periods_on_month"
  end

  create_table "relationship_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
  end

  create_table "reporting_entities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_reporting_entities_on_name", unique: true
  end

  create_table "reporting_units", force: :cascade do |t|
    t.string "name"
    t.bigint "reporting_entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reporting_entity_id"], name: "index_reporting_units_on_reporting_entity_id"
  end

  create_table "rp_consolidations", force: :cascade do |t|
    t.bigint "rp_master_id", null: false
    t.bigint "reporting_entity_id", null: false
    t.bigint "period_id", null: false
    t.date "related_party_from"
    t.date "related_party_upto"
    t.string "custom_input"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period_id"], name: "index_rp_consolidations_on_period_id"
    t.index ["reporting_entity_id"], name: "index_rp_consolidations_on_reporting_entity_id"
    t.index ["rp_master_id", "reporting_entity_id", "period_id"], name: "idx_rp_consolidations_composite"
    t.index ["rp_master_id", "reporting_entity_id", "period_id"], name: "idx_rp_consolidations_master_entity_period"
    t.index ["rp_master_id"], name: "index_rp_consolidations_on_rp_master_id"
  end

  create_table "rp_masters", force: :cascade do |t|
    t.string "unique_code"
    t.string "salutation"
    t.string "name"
    t.string "category"
    t.string "specific_relationship"
    t.date "dob_or_incorporation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pan"
    t.boolean "related_party_sebi"
    t.boolean "related_party_companies_act"
    t.boolean "related_party_as18"
    t.boolean "related_party_ind_as24"
    t.string "other_guidelines"
    t.boolean "active"
    t.string "related_to_director", default: "false"
    t.bigint "created_by_id"
    t.bigint "approved_by_id"
    t.bigint "admin_approved_by_id"
    t.index ["active"], name: "index_rp_masters_on_active"
    t.index ["admin_approved_by_id"], name: "index_rp_masters_on_admin_approved_by_id"
    t.index ["approved_by_id"], name: "index_rp_masters_on_approved_by_id"
    t.index ["category"], name: "index_rp_masters_on_category"
    t.index ["created_by_id"], name: "index_rp_masters_on_created_by_id"
    t.index ["name"], name: "index_rp_masters_on_name"
    t.index ["pan"], name: "index_rp_masters_on_pan"
    t.index ["related_party_companies_act"], name: "index_rp_masters_on_related_party_companies_act"
    t.index ["related_party_sebi"], name: "index_rp_masters_on_related_party_sebi"
    t.index ["specific_relationship"], name: "index_rp_masters_on_specific_relationship"
    t.index ["unique_code"], name: "index_rp_masters_on_unique_code"
  end

  create_table "rp_transactions", force: :cascade do |t|
    t.bigint "reporting_entity_id", null: false
    t.bigint "reporting_unit_id", null: false
    t.bigint "period_id", null: false
    t.string "counterparty", null: false
    t.string "transaction_type", null: false
    t.string "nature", null: false
    t.string "sub_nature", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period_id"], name: "index_rp_transactions_on_period_id"
    t.index ["reporting_entity_id", "reporting_unit_id", "period_id", "counterparty", "nature", "sub_nature", "transaction_type"], name: "idx_rp_transactions_upsert_match"
    t.index ["reporting_entity_id"], name: "index_rp_transactions_on_reporting_entity_id"
    t.index ["reporting_unit_id"], name: "index_rp_transactions_on_reporting_unit_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "nature"
    t.string "transaction_type"
    t.string "sub_type"
    t.string "as18"
    t.string "acb"
    t.string "sebi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.boolean "elimination_required"
    t.integer "ic_code"
    t.string "main_code"
    t.string "sub_code"
    t.string "opposite_sub_code"
    t.index ["active"], name: "index_transactions_on_active"
    t.index ["nature", "sub_type"], name: "idx_transactions_nature_sub_type"
    t.index ["nature"], name: "index_transactions_on_nature"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "reporting_units", "reporting_entities"
  add_foreign_key "rp_consolidations", "periods"
  add_foreign_key "rp_consolidations", "reporting_entities"
  add_foreign_key "rp_consolidations", "rp_masters"
  add_foreign_key "rp_masters", "users", column: "admin_approved_by_id"
  add_foreign_key "rp_masters", "users", column: "approved_by_id"
  add_foreign_key "rp_masters", "users", column: "created_by_id"
  add_foreign_key "rp_transactions", "periods"
  add_foreign_key "rp_transactions", "reporting_entities"
  add_foreign_key "rp_transactions", "reporting_units"
end
