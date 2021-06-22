class ColorsController < ApplicationController
  def get_colors
    # byebug
    Color.get_colors
    palette_total = Palette.all.count
    palette_unused = Palette.where(used: false).count

    palette = {
      total: palette_total,
      unused: palette_unused
    }
    render json: palette
  end
end