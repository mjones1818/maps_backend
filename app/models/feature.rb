class Feature < ApplicationRecord
  belongs_to :style
  has_one :color, dependent: :destroy
  # has_many :colors
  # has_many :feature_colors
  # has_many :colors, through: :feature_colors
end
