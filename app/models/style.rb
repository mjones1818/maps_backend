class Style < ApplicationRecord
  has_many :features, dependent: :destroy

  attr_accessor :colors
  BASE_URL = 'https://api.mapbox.com/styles/v1/'
  USER_ID = 'mjones1818'
  @@colors = {
    land: {
      name: 'Saffron',
      code: '#E3B505'
    },
    water: {
      name: 'Yale Blue',
      code: '#044B7F'
    },
    roads: {
      name: 'Tyrian Purple',
      code: '#610345'
    }
  }

  def self.rcm(name='RCM')
    # puts 'enter id'
    # id = gets.chomp
    style = Style.first
    style.delete_style
    style.new_style
  end

  def self.clear
    Style.destroy_all
    Feature.destroy_all
    Color.destroy_all
  end

  def self.colors
    @@colors
  end

  def self.get_styles
    uri = URI.parse("#{BASE_URL+USER_ID}/?access_token=#{ENV['API_KEY']}")
    response = Net::HTTP.get_response(uri)
    json_response = JSON.parse(response.body)
    json_response.each do |style|
      Style.add_style_to_db(style)
    end
  end

  def get_style_data(style_id=self.style_id)
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style_id}?access_token=#{ENV['API_KEY']}")
    response = Net::HTTP.get_response(uri)
    json_response = JSON.parse(response.body)
  end

  def prepare_for_update(name=nil)
    style_object = self.modify_map(self.style_object,name)
    keys_to_remove = ['created', 'modified', 'id', 'owner']
    style_object.delete_if {|k,v| keys_to_remove.include?(k)}
    style_object.to_json
  end
  
  def update_style(style=self.style_id)
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style}?access_token=#{ENV['API_KEY']}")
    request = Net::HTTP::Patch.new(uri)
    request.content_type = "application/json"
    request.body = ""
    request.body << self.prepare_for_update

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

  end

  def modify_map(style_object,name=nil,colors=@@colors)
    if name
      style_object['name'] = "RCM - #{colors[:land][:name]}, #{colors[:water][:name]}, #{colors[:roads][:name]}"
    end
    style_object['layers'].each do |layer|
      if layer['id'] == 'land'
        layer['paint']['background-color'] = colors[:land][:code]
      elsif layer['id'] == 'water'
        layer['paint']['fill-color'] = colors[:water][:code]
      else
        layer['paint']['line-color'] = colors[:roads][:code]
      end
    end
    style_object
  end

  def new_style
    uri = URI.parse("#{BASE_URL+USER_ID}/?access_token=#{ENV['API_KEY']}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = ""
    request.body << self.prepare_for_update(true)
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    # byebug
    json = JSON.parse(response.body)
    Style.add_style_to_db(json)
  end

  def delete_style(stlye_id=self.style_id)
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style_id}?access_token=#{ENV['API_KEY']}")
    request = Net::HTTP::Delete.new(uri)
    req_options = {
      use_ssl: uri.scheme == 'https',
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    self.destroy
  end

  def self.add_style_to_db(style)
    new_style = Style.find_or_create_by(style_id: style['id'])
    new_style[:name] = style['name']
    new_style[:style_id] = style['id']
    updated_object = new_style.get_style_data(style['id'])
    new_style[:style_object] = updated_object
    updated_object['layers'].each do |layer|
      if layer['id'] == 'land'
        land = new_style.features.build(name: 'land')
        color = Color.new(name:'existing', code:layer['paint']['background-color'])
        land.color = color
        land.save
      elsif layer['id'] == 'water'
        water = new_style.features.build(name: 'water')
        color = Color.new(name:'existing', code:layer['paint']['fill-color'])
        water.color = color
        water.save
      else
        roads = new_style.features.build(name: 'roads')
        color = Color.new(name:'existing', code: layer['paint']['line-color'])
        roads.color = color
        roads.save
      end
    end
    new_style.save
  end
end
