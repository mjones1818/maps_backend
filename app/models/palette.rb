class Palette < ApplicationRecord
  has_many :palette_colors, dependent: :destroy
end
