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

ActiveRecord::Schema[8.1].define(version: 2026_03_11_130148) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "audit_entries", force: :cascade do |t|
    t.bigint "auditable_id", null: false
    t.string "auditable_type", null: false
    t.jsonb "changes_data", default: {}
    t.datetime "created_at", null: false
    t.string "event", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "whodunnit"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_entries_on_auditable"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_entries_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_entries_on_user_id"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["product_id"], name: "index_order_line_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "carrier"
    t.datetime "created_at", null: false
    t.string "customer_email", null: false
    t.string "customer_name", null: false
    t.text "notes"
    t.string "reference", null: false
    t.string "status", default: "pending", null: false
    t.integer "total_cents", default: 0, null: false
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["customer_email"], name: "index_orders_on_customer_email"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "sku", null: false
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_products_on_sku", unique: true
  end

  create_table "tracking_events", force: :cascade do |t|
    t.string "carrier", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.datetime "occurred_at", null: false
    t.bigint "order_id", null: false
    t.jsonb "raw_payload", default: {}
    t.string "status", null: false
    t.string "tracking_number", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id", "occurred_at"], name: "index_tracking_events_on_order_id_and_occurred_at"
    t.index ["order_id"], name: "index_tracking_events_on_order_id"
    t.index ["tracking_number"], name: "index_tracking_events_on_tracking_number"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.boolean "staff", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "audit_entries", "users"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "tracking_events", "orders"
end
