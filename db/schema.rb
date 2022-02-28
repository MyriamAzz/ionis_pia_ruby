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

ActiveRecord::Schema.define(version: 2022_02_07_134236) do

  create_table "accounting_alerts", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "centre_id"
    t.bigint "user_id"
    t.bigint "user_financier_subscription_id"
    t.integer "atype"
    t.integer "status", default: 0
    t.string "comment"
    t.float "amount"
    t.integer "handled_by_id"
    t.string "comment_1"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_accounting_alerts_on_centre_id"
    t.index ["user_financier_subscription_id"], name: "index_accounting_alerts_on_user_financier_subscription_id"
    t.index ["user_id"], name: "index_accounting_alerts_on_user_id"
  end

  create_table "active_storage_attachments", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "administrators", charset: "utf8mb4", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "centre_customer_accounts", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "centre_id"
    t.bigint "school_year_id"
    t.string "compte_client_sage"
    t.integer "num_facture", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_centre_customer_accounts_on_centre_id"
    t.index ["school_year_id"], name: "index_centre_customer_accounts_on_school_year_id"
  end

  create_table "centres", charset: "utf8mb4", force: :cascade do |t|
    t.integer "school_program_id"
    t.string "nom"
    t.string "acronyme"
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.string "tel"
    t.string "siret"
    t.string "num_immatriculation"
    t.string "ics"
    t.string "code_sage"
    t.integer "compte_client_sage"
    t.integer "compte_banque_sage"
    t.integer "compte_attente_sage"
    t.integer "compte_client_sage_alt"
    t.string "gocardless_token"
    t.string "gocardless_endpoint_secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "formation_annees", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "formation_id"
    t.bigint "school_year_id"
    t.float "frais_inscription"
    t.float "frais_technique"
    t.float "frais_bde"
    t.float "modalite_1"
    t.float "modalite_2"
    t.float "modalite_3"
    t.float "modalite_4"
    t.float "modalite_5"
    t.float "modalite_6"
    t.float "modalite_7"
    t.float "modalite_8"
    t.float "modalite_9"
    t.float "modalite_10"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["formation_id"], name: "index_formation_annees_on_formation_id"
    t.index ["school_year_id"], name: "index_formation_annees_on_school_year_id"
  end

  create_table "formations", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "centre_id"
    t.string "nom"
    t.string "code"
    t.integer "compte_produit_sage"
    t.boolean "archived", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_formations_on_centre_id"
  end

  create_table "log_sales", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_financier_subscription_id"
    t.integer "user_financier_subscription_instalment_id"
    t.integer "user_financier_subscription_credit_id"
    t.string "code_journal"
    t.date "date_import"
    t.string "numero_facture"
    t.string "reference"
    t.string "compte_general"
    t.string "compte_tiers"
    t.string "libelle"
    t.string "type_ecriture"
    t.string "analytique"
    t.string "mode_reglement"
    t.date "date_echeance"
    t.decimal "debit", precision: 10, scale: 2
    t.decimal "credit", precision: 10, scale: 2
    t.string "nom_complet"
    t.integer "annee"
    t.integer "type_frais"
    t.integer "modalite"
    t.boolean "exported", default: false
    t.datetime "exported_at"
    t.integer "exported_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_financier_subscription_id"], name: "index_log_sales_on_user_financier_subscription_id"
  end

  create_table "payment_calendars", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "school_year_id"
    t.integer "plan"
    t.integer "plan_order"
    t.date "plan_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_year_id"], name: "index_payment_calendars_on_school_year_id"
  end

  create_table "payment_plans", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "school_program_id"
    t.integer "plan"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_program_id"], name: "index_payment_plans_on_school_program_id"
  end

  create_table "payouts", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "school_program_id"
    t.bigint "centre_id"
    t.bigint "user_id"
    t.integer "gc_status"
    t.string "gc_id"
    t.string "gc_reference"
    t.decimal "gc_amount", precision: 10, scale: 2
    t.datetime "gc_created_at"
    t.datetime "gc_arrival_at"
    t.boolean "exported", default: false
    t.datetime "exported_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_payouts_on_centre_id"
    t.index ["school_program_id"], name: "index_payouts_on_school_program_id"
    t.index ["user_id"], name: "index_payouts_on_user_id"
  end

  create_table "school_programs", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "school_id"
    t.string "nom"
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.string "resp_nom"
    t.string "resp_prenom"
    t.string "resp_fonction"
    t.string "email_from"
    t.string "email_contact"
    t.string "ics"
    t.string "footer_1"
    t.string "footer_2"
    t.boolean "gocardless_general", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_school_programs_on_school_id"
  end

  create_table "school_years", charset: "utf8mb4", force: :cascade do |t|
    t.integer "school_program_id"
    t.string "nom"
    t.date "debut"
    t.date "fin"
    t.integer "frais_inscription_jours"
    t.date "frais_techniques_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "schools", charset: "utf8mb4", force: :cascade do |t|
    t.string "nom"
    t.string "couleur"
    t.string "grape_api_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_admin_centres", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "centre_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_user_admin_centres_on_centre_id"
    t.index ["user_id"], name: "index_user_admin_centres_on_user_id"
  end

  create_table "user_admin_school_programs", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_program_id"], name: "index_user_admin_school_programs_on_school_program_id"
    t.index ["user_id"], name: "index_user_admin_school_programs_on_user_id"
  end

  create_table "user_admin_schools", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "school_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["school_id"], name: "index_user_admin_schools_on_school_id"
    t.index ["user_id"], name: "index_user_admin_schools_on_user_id"
  end

  create_table "user_admins", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "centre_id"
    t.string "nom"
    t.string "prenom"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_admins_on_user_id"
  end

  create_table "user_financier_mandates", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_financier_id"
    t.string "rum"
    t.string "nom"
    t.string "prenom"
    t.string "email"
    t.string "adresse"
    t.string "cp"
    t.string "ville"
    t.string "pays"
    t.string "iban"
    t.string "bic"
    t.string "adresse_ip"
    t.boolean "actif", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_financier_id"], name: "index_user_financier_mandates_on_user_financier_id"
  end

  create_table "user_financier_rib_events", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_financier_id"
    t.string "gocardless_id"
    t.string "gocardless_mandate_id"
    t.integer "gocardless_status"
    t.string "gocardless_cause"
    t.string "gocardless_reason_code"
    t.string "gocardless_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_financier_ribs", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_financier_id"
    t.string "iban"
    t.string "bic"
    t.string "rum"
    t.string "gocardless_account_id"
    t.string "gocardless_mandate_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_financier_id"], name: "index_user_financier_ribs_on_user_financier_id"
  end

  create_table "user_financier_subscription_credits", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_financier_subscription_id"
    t.bigint "user_financier_subscription_instalment_id"
    t.integer "creator_id"
    t.string "facture_ref"
    t.date "echeance"
    t.float "montant"
    t.string "code_export"
    t.string "libelle"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_financier_subscription_id"], name: "index_subscription_credits_on_subscription_id"
    t.index ["user_financier_subscription_instalment_id"], name: "index_subscription_credits_on_instalment_id"
  end

  create_table "user_financier_subscription_instalment_events", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_financier_subscription_instalment_id"
    t.string "gocardless_id"
    t.integer "gocardless_status"
    t.string "gocardless_cause"
    t.string "gocardless_description"
    t.datetime "gocardless_date", precision: 3
    t.boolean "done", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_financier_subscription_instalments", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_financier_subscription_id"
    t.integer "payout_id"
    t.integer "statut"
    t.date "echeance"
    t.float "montant"
    t.float "montant_initial"
    t.string "facture"
    t.integer "v_type"
    t.integer "v_mode"
    t.string "gocardless_id"
    t.boolean "formation_changed", default: false
    t.boolean "need_accounted", default: true
    t.boolean "custom_line", default: false
    t.boolean "can_force_turnover", default: false
    t.boolean "refunded", default: false
    t.boolean "rescheduled", default: false
    t.datetime "refunded_at"
    t.boolean "exported", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_financier_subscriptions", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_financier_id"
    t.bigint "formation_annee_id"
    t.bigint "school_year_id"
    t.string "month_start"
    t.integer "s_type"
    t.integer "modalite"
    t.integer "reduction"
    t.integer "reduction_type"
    t.integer "statut"
    t.boolean "redoublant", default: false
    t.integer "statut_etu"
    t.boolean "special_case", default: false
    t.integer "payment_mode_inscription"
    t.date "payment_mode_inscription_cb_date"
    t.string "payment_mode_inscription_comment"
    t.integer "payment_mode_scolarite"
    t.string "payment_mode_scolarite_comment"
    t.boolean "frais_inscription_done", default: false
    t.boolean "frais_techniques_done", default: false
    t.boolean "frais_scolarite_done", default: false
    t.datetime "frais_inscription_done_date"
    t.datetime "frais_techniques_done_date"
    t.datetime "frais_scolarite_done_date"
    t.boolean "etudiant_confirm_reinscription", default: false
    t.datetime "etudiant_reinscription_done_date"
    t.integer "updated_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["formation_annee_id"], name: "index_user_financier_subscriptions_on_formation_annee_id"
    t.index ["school_year_id"], name: "index_user_financier_subscriptions_on_school_year_id"
    t.index ["user_financier_id"], name: "index_user_financier_subscriptions_on_user_financier_id"
  end

  create_table "user_financier_timelines", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "user_financier_id"
    t.integer "user_financier_subscription_id"
    t.string "descr"
    t.boolean "comment", default: false
    t.boolean "comment_pin", default: false
    t.integer "priority"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_financier_timelines_on_user_id"
  end

  create_table "user_financiers", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "centre_id"
    t.boolean "imported", default: false
    t.string "nom"
    t.string "prenom"
    t.string "adresse"
    t.string "adresse_2"
    t.string "code_postal"
    t.string "ville"
    t.string "pays"
    t.string "tel"
    t.string "etu_nom"
    t.string "etu_prenom"
    t.string "etu_email"
    t.string "etu_adresse"
    t.string "etu_ville"
    t.string "etu_code_postal"
    t.string "etu_pays"
    t.string "etu_tel"
    t.string "etu_famille_ionis"
    t.string "etu_famille_ionis_prenom"
    t.string "etu_famille_ionis_nom"
    t.string "etu_id_sf"
    t.string "code_tiers"
    t.string "gocardless_customer_id"
    t.boolean "dont_relaunch", default: false
    t.text "dont_relaunch_comment"
    t.boolean "follow", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["centre_id"], name: "index_user_financiers_on_centre_id"
    t.index ["user_id"], name: "index_user_financiers_on_user_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "uuid", limit: 36
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "role"
    t.boolean "archived", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
