class Color < ApplicationRecord
  belongs_to :feature, dependent: :destroy

  def destroy
    self.delete
  end

  # document.getElementById('modal-fabrizio').children[0].children[1].children[0].children[0].click()
  # document.getElementById('whats-new').children[0].children[1].children[0].children[1].click()
  # document.getElementById('generator-tutorial-intro').children[0].children[1].children[0].children[2].click()
  def self.get_colors
    # html = open("http://coolors.co/4e5166-7c90a0-b5aa9d-b9b7a7-747274")
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto('http://coolors.co/4e5166-7c90a0-b5aa9d-b9b7a7-747274')
    # doc = Nokogiri::HTML(URI.open("http://coolors.co/4e5166-7c90a0-b5aa9d-b9b7a7-747274"))
    # js_doc = browser.element(css: '.generator_color_hex').wait_until(&:present?)
    colors = browser.element(css: '#generator_colors').wait_until(&:present?)
    first_color = colors.children[0].children[1].children[0].inner_html
    color_object = {}
    colors.children.each do |color|
      color_object[color.children[1].children[1].inner_text] = color.children[1].children[0].inner_text
    end
    # doc = Nokogiri::HTML(colors.inner_html)
    # byebug
    puts color_object
  end
end
