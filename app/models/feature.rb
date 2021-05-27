class Feature < ApplicationRecord
  belongs_to :style
  has_one :color, dependent: :destroy
 
  def destroy
    self.color.destroy
    self.delete
  end
end
