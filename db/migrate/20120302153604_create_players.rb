class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.boolean :player_1,

      t.timestamps
    end
  end
end
