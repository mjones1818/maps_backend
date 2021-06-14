class ColorsController < ApplicationController
  def get_colors
    # byebug
    Color.get_colors
  end
end