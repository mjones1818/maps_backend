class CreatePaletteColors < ActiveRecord::Migration[6.1]
  def change
    create_table :palette_colors do |t|
      t.string :name
      t.string :code
      t.integer :palette_id
      t.timestamps
    end
  end
end
