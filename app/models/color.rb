class Color < ApplicationRecord
  belongs_to :feature, dependent: :destroy
  attr_accessor :color_object

  def destroy
    self.delete
  end

  # document.getElementById('modal-fabrizio').children[0].children[1].children[0].children[0].click()
  # document.getElementById('whats-new').children[0].children[1].children[0].children[1].click()
  # document.getElementById('generator-tutorial-intro').children[0].children[1].children[0].children[2].click()
  # def initialize(variable)
  #   # byebug
  #   @color_object = self.get_colors
  # end
  
  def get_colors
    # browser = Watir::Browser.new :chrome, headless: true
    # browser = Watir::Browser.new :chrome
    browser = Watir::Browser.new :safari, headless: true
    Watir.default_timeout = 40
    browser.goto('http://coolors.co/generate')

    # byebug
    colors = browser.element(css: '#generator_colors').wait_until(&:present?)
    first_color = colors.children[0].children[1].children[0].inner_html
    color_object = {}
    colors.children.each do |color|
      color_object[color.children[1].children[1].inner_text] = color.children[1].children[0].inner_text
    end
    browser.close
    new_palette = Palette.new
    color_object.each do |k,v|
      color = PaletteColor.create(
        name: k,
        code: "##{v}"
      )
      new_palette.palette_colors << color
    end
    new_palette.save
    color_object
  end

  def assign_colors
    @color_object = {
      Saffron: '#e3bdsf',
      Saffron1: '#e3sf1',
      Saffron2: '#e3bdsf2',
      Saffron3: '#e3bdsf3',
      Saffron4: '#e3bdsf4'
    }
    @color_object = self.get_colors
    colors = {}
    features =['land','water','roads','unassigned1','unassigned2']
    i = 0
    @color_object.each do |k,v|
      colors[features[i].to_sym] = {
        name: k.to_s,
        code: "##{v}"
      }
      i +=1
    end
    colors
  end

  def assign_colors_from_db
    
    @color_object = {}
    random_unused_palette = Palette.where(used: false).sample
    random_unused_palette.palette_colors.each do |color|
      @color_object[color.name] = color.code
    end
    colors = {}
    features =['land','water','roads','unassigned1','unassigned2']
    i = 0
    @color_object.each do |k,v|
      colors[features[i].to_sym] = {
        name: k.to_s,
        code: v
      }
      i +=1
    end
    random_unused_palette.toggle :used
    random_unused_palette.save
    colors
  end
end
