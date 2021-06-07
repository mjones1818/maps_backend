class CreatePalettes < ActiveRecord::Migration[6.1]
  def change
    create_table :palettes do |t|

      t.timestamps
    end
  end
end
