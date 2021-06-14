class StylesController < ApplicationController
  def index
    styles = Style.all
    render json: styles
  end

  def get_map
    # byebug
    style = Style.last.get_map
    render json: style
  end

  def rcm
    style = Style.rcm
    # byebug
    style.style_object['map_url'] = style.get_map
    render json: style
  end

  def save_style
    # byebug
    style =Style.save_style(params['style_id'])
    render json: style
  end
end