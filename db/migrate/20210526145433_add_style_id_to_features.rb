class AddStyleIdToFeatures < ActiveRecord::Migration[6.1]
  def change
    add_column :features, :style_id, :integer
  end
end
