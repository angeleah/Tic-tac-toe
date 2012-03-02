class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.boolean :player_1, :default => false

      t.timestamps
    end
  end
end
