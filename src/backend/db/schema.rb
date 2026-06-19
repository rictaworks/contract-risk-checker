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

ActiveRecord::Schema[8.1].define(version: 2026_06_19_015720) do
  create_table "clauses", force: :cascade do |t|
    t.string "clause_number"
    t.text "clause_text", null: false
    t.string "clause_title"
    t.integer "contract_id", null: false
    t.datetime "created_at", null: false
    t.integer "order_index", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_clauses_on_contract_id"
    t.index ["order_index"], name: "index_clauses_on_order_index"
  end

  create_table "contract_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_contract_types_on_name", unique: true
  end

  create_table "contracts", force: :cascade do |t|
    t.integer "contract_type_id"
    t.datetime "created_at", null: false
    t.text "extracted_text"
    t.integer "file_size_bytes"
    t.string "original_filename", null: false
    t.string "status", default: "UPLOADED", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["contract_type_id"], name: "index_contracts_on_contract_type_id"
    t.index ["status"], name: "index_contracts_on_status"
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "contract_id", null: false
    t.datetime "created_at", null: false
    t.integer "high_count", default: 0
    t.integer "low_count", default: 0
    t.integer "medium_count", default: 0
    t.text "overall_comment"
    t.string "pdf_path"
    t.integer "total_score"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_reports_on_contract_id", unique: true
  end

  create_table "risk_analyses", force: :cascade do |t|
    t.string "analysis_status", default: "PENDING", null: false
    t.integer "clause_id", null: false
    t.datetime "created_at", null: false
    t.text "problem_description"
    t.integer "retry_count", default: 0
    t.integer "risk_level_id"
    t.integer "risk_type_id"
    t.text "suggestion_text"
    t.datetime "updated_at", null: false
    t.index ["analysis_status"], name: "index_risk_analyses_on_analysis_status"
    t.index ["clause_id"], name: "index_risk_analyses_on_clause_id", unique: true
    t.index ["risk_level_id"], name: "index_risk_analyses_on_risk_level_id"
    t.index ["risk_type_id"], name: "index_risk_analyses_on_risk_type_id"
  end

  create_table "risk_levels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "score_weight", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_risk_levels_on_name", unique: true
  end

  create_table "risk_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_risk_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "display_name"
    t.string "google_sub", null: false
    t.datetime "updated_at", null: false
    t.index ["google_sub"], name: "index_users_on_google_sub", unique: true
  end

  add_foreign_key "clauses", "contracts"
  add_foreign_key "contracts", "contract_types"
  add_foreign_key "contracts", "users"
  add_foreign_key "reports", "contracts"
  add_foreign_key "risk_analyses", "clauses"
  add_foreign_key "risk_analyses", "risk_levels"
  add_foreign_key "risk_analyses", "risk_types"
end
