class CreateFeatureColors < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_colors do |t|
      t.integer :feature_id
      t.integer :color_id

      t.timestamps
    end
  end
end
