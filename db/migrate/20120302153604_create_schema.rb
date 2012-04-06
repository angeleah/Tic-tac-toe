class CreateSchema < ActiveRecord::Migration
  def change    
    create_table "boards", :force => true do |t|
      t.string   "s0"
      t.string   "s1"
      t.string   "s2"
      t.string   "s3"
      t.string   "s4"
      t.string   "s5"
      t.string   "s6"
      t.string   "s7"
      t.string   "s8"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "players", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_first"
    end

    create_table "turns", :force => true do |t|
      t.string   "player"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
