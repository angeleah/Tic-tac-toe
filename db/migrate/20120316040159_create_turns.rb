class CreateTurns < ActiveRecord::Migration
  def change
    create_table :turns do |t|
      t.string :player

      t.timestamps
    end
  end
end
