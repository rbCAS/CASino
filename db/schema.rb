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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130203155008) do

  create_table "login_tickets", :force => true do |t|
    t.string   "ticket",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "login_tickets", ["ticket"], :name => "index_login_tickets_on_ticket", :unique => true

  create_table "proxy_granting_tickets", :force => true do |t|
    t.string   "ticket",       :null => false
    t.string   "iou",          :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "granter_id",   :null => false
    t.string   "pgt_url",      :null => false
    t.string   "granter_type", :null => false
  end

  add_index "proxy_granting_tickets", ["granter_type", "granter_id"], :name => "index_proxy_granting_tickets_on_granter_type_and_granter_id", :unique => true
  add_index "proxy_granting_tickets", ["iou"], :name => "index_proxy_granting_tickets_on_iou", :unique => true
  add_index "proxy_granting_tickets", ["ticket"], :name => "index_proxy_granting_tickets_on_ticket", :unique => true

  create_table "proxy_tickets", :force => true do |t|
    t.string   "ticket",                                      :null => false
    t.string   "service",                                     :null => false
    t.boolean  "consumed",                 :default => false, :null => false
    t.integer  "proxy_granting_ticket_id",                    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "proxy_tickets", ["proxy_granting_ticket_id"], :name => "index_proxy_tickets_on_proxy_granting_ticket_id"
  add_index "proxy_tickets", ["ticket"], :name => "index_proxy_tickets_on_ticket", :unique => true

  create_table "service_rules", :force => true do |t|
    t.boolean  "enabled",    :default => true,  :null => false
    t.integer  "order",      :default => 10,    :null => false
    t.string   "name",                          :null => false
    t.string   "url",                           :null => false
    t.boolean  "regex",      :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "service_rules", ["url"], :name => "index_service_rules_on_url", :unique => true

  create_table "service_tickets", :force => true do |t|
    t.string   "ticket",                                       :null => false
    t.string   "service",                                      :null => false
    t.integer  "ticket_granting_ticket_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.boolean  "consumed",                  :default => false, :null => false
    t.boolean  "issued_from_credentials",   :default => false, :null => false
  end

  add_index "service_tickets", ["ticket"], :name => "index_service_tickets_on_ticket", :unique => true
  add_index "service_tickets", ["ticket_granting_ticket_id"], :name => "index_service_tickets_on_ticket_granting_ticket_id"

  create_table "ticket_granting_tickets", :force => true do |t|
    t.string   "ticket",                                                :null => false
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "user_agent"
    t.integer  "user_id",                                               :null => false
    t.boolean  "awaiting_two_factor_authentication", :default => false, :null => false
  end

  add_index "ticket_granting_tickets", ["ticket"], :name => "index_ticket_granting_tickets_on_ticket", :unique => true

  create_table "two_factor_authenticators", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.string   "secret",                        :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "active",     :default => false, :null => false
  end

  add_index "two_factor_authenticators", ["user_id"], :name => "index_two_factor_authenticators_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "authenticator",    :null => false
    t.string   "username",         :null => false
    t.text     "extra_attributes"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "users", ["authenticator", "username"], :name => "index_users_on_authenticator_and_username", :unique => true

end
