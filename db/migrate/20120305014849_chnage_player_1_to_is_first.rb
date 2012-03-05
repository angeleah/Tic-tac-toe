class ChnagePlayer1ToIsFirst < ActiveRecord::Migration
  def up
    remove_column :players, :is_first
    add_column :players, :is_first, :boolean
  end

  def down
    remove_column :players, :is_first
    add_column :players, :is_first, :boolean
  end
end
