class CreateStyles < ActiveRecord::Migration[6.1]
  def change
    create_table :styles do |t|
      t.string :name
      t.string :style_id
      t.jsonb :style_object

      t.timestamps
    end
  end
end
