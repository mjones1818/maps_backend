class Style < ApplicationRecord
  has_many :features, dependent: :destroy

  attr_accessor :colors
  BASE_URL = 'https://api.mapbox.com/styles/v1/'
  USER_ID = 'mjones1818'
  @@colors = {
    land: {
      name: 'Battleship Grey',
      code: '#16302B'
    },
    water: {
      name: 'Opal',
      code: '#9D79BC'
    },
    roads: {
      name: 'Outer Space Crayola',
      code: '#85B79D'
    }
  }

  def self.rcm(name='RCM')
    style = Style.where(name: name).first
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
      # new_style = Style.find_or_create_by(style_id: style['id'])
      # new_style[:name] = style['name']
      # new_style[:style_id] = style['id']
      # updated_object = new_style.get_style_data(style['id'])
      # new_style[:style_object] = updated_object
      # updated_object['layers'].each do |layer|
      #   if layer['id'] == 'land'
      #     land = new_style.features.build(name: 'land')
      #     color = Color.new(name:'existing', code:layer['paint']['background-color'])
      #     land.color = color
      #     land.save
      #   elsif layer['id'] == 'water'
      #     water = new_style.features.build(name: 'water')
      #     color = Color.new(name:'existing', code:layer['paint']['fill-color'])
      #     water.color = color
      #     water.save
      #   else
      #     roads = new_style.features.build(name: 'roads')
      #     color = Color.new(name:'existing', code: layer['paint']['line-color'])
      #     roads.color = color
      #     roads.save
      #   end
      Style.add_style_to_db(style)
      # end
      # new_style.save
    end
  end

  def get_style_data(style_id=self.style_id)
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style_id}?access_token=#{ENV['API_KEY']}")
    response = Net::HTTP.get_response(uri)
    json_response = JSON.parse(response.body)
  end

  def prepare_for_update
    style_object = self.modify_map(self.style_object)
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

  def modify_map(style_object,colors=@@colors)
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
    request.body << self.prepare_for_update
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
