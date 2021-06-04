class Color < ApplicationRecord
  belongs_to :feature, dependent: :destroy

  def destroy
    self.delete
  end

  # document.getElementById('modal-fabrizio').children[0].children[1].children[0].children[0].click()
  # document.getElementById('whats-new').children[0].children[1].children[0].children[1].click()
  # document.getElementById('generator-tutorial-intro').children[0].children[1].children[0].children[2].click()
  def self.get_colors
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto('http://coolors.co/generate')
    colors = browser.element(css: '#generator_colors').wait_until(&:present?)
    first_color = colors.children[0].children[1].children[0].inner_html
    color_object = {}
    colors.children.each do |color|
      color_object[color.children[1].children[1].inner_text] = color.children[1].children[0].inner_text
    end
    color_object
  end
end
