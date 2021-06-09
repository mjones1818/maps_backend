class AddUsedToPalette < ActiveRecord::Migration[6.1]
  def change
    add_column :palettes, :used, :boolean, default: false
  end
end
