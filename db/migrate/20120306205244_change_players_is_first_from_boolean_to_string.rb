class ChangePlayersIsFirstFromBooleanToString < ActiveRecord::Migration
  def up
    remove_column :players, :is_first, :boolean
    add_column :players, :is_first, :string
  end

  def down
    remove_column :players, :is_first, :string
    add_column :players, :is_first, :boolean
  end
end
