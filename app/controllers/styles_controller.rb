class StylesController < ApplicationController
  def index
    styles = Style.all
    render json: styles
  end

  def get_map
    style = Style.last.get_map
    render json: style
  end

  def rcm
    byebug
    Style.rcm
  end
end