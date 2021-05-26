class Color < ApplicationRecord
  belongs_to :feature
  # has_many :feature_colors
  # has_many :styles, through: :feature_colors
end
