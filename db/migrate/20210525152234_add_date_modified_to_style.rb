class AddDateModifiedToStyle < ActiveRecord::Migration[6.1]
  def change
    add_column :styles, :date_modified, :string
  end
end
