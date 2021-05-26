class StylesController < ApplicationController
  def index
    stlyes = Style.all
    render json: stlyes
  end
end