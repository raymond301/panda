# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140417182714) do

  create_table "annotation_collections", force: true do |t|
    t.string   "name"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "originator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotation_collections", ["originator_id"], name: "index_annotation_collections_on_originator_id", using: :btree

  create_table "annotation_collections_groups", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "annotation_collection_id"
  end

  create_table "enrichments", force: true do |t|
    t.string   "name"
    t.integer  "annotation_collection_id"
    t.integer  "originator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enrichments", ["originator_id"], name: "index_enrichments_on_originator_id", using: :btree

  create_table "gene_synonyms", force: true do |t|
    t.integer "gene_id"
    t.string  "define"
    t.string  "name"
  end

  add_index "gene_synonyms", ["name"], name: "index_gene_synonyms_on_name", unique: true, using: :btree

  create_table "genes", force: true do |t|
    t.string "symbol",   null: false
    t.string "fullname"
  end

  add_index "genes", ["symbol"], name: "index_genes_on_symbol", unique: true, using: :btree

  create_table "genes_pathways", id: false, force: true do |t|
    t.integer "pathway_id"
    t.integer "gene_id"
  end

  add_index "genes_pathways", ["gene_id"], name: "index_genes_pathways_on_gene_id", using: :btree
  add_index "genes_pathways", ["pathway_id"], name: "index_genes_pathways_on_pathway_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name",            default: "MyGroup"
    t.string   "visibility"
    t.string   "description"
    t.string   "aggregated_type"
    t.integer  "originator"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "pathway_counts", force: true do |t|
    t.string  "xref"
    t.string  "countable_type"
    t.integer "countable_id"
    t.decimal "count",          precision: 8, scale: 4, default: 0.0
  end

  add_index "pathway_counts", ["countable_id"], name: "index_pathway_counts_on_countable_id", using: :btree
  add_index "pathway_counts", ["xref"], name: "index_pathway_counts_on_xref", using: :btree

  create_table "pathway_images", force: true do |t|
    t.string   "xref"
    t.integer  "img_height"
    t.integer  "img_width"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pathway_images", ["xref"], name: "index_pathway_images_on_xref", using: :btree

  create_table "pathway_maps", force: true do |t|
    t.string  "name"
    t.string  "url"
    t.string  "source"
    t.string  "xref"
    t.integer "originator"
    t.text    "ent_url"
    t.string  "ent_name"
    t.string  "ent_shape"
    t.string  "x"
    t.string  "y"
    t.string  "gene_symbol"
    t.text    "coords"
    t.text    "pt",                       limit: 16777215
    t.integer "annotation_collection_id"
  end

  add_index "pathway_maps", ["annotation_collection_id"], name: "index_pathway_maps_on_annotation_collection_id", using: :btree
  add_index "pathway_maps", ["gene_symbol"], name: "index_pathway_maps_on_gene_symbol", using: :btree
  add_index "pathway_maps", ["originator"], name: "index_pathway_maps_on_originator", using: :btree
  add_index "pathway_maps", ["xref"], name: "index_pathway_maps_on_xref", using: :btree

  create_table "pathways", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "source"
    t.string   "xref"
    t.integer  "originator"
    t.string   "file"
    t.text     "gene_id_list"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username",                               null: false
    t.string   "email",                  default: ""
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                  default: false
    t.integer  "current_group_id",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
