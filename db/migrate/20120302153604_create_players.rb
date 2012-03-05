class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.boolean :is_first,

      t.timestamps
    end
  end
end
