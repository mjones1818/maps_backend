class PaletteColor < ApplicationRecord
  belongs_to :palette

  def destroy
    self.delete
  end
end
