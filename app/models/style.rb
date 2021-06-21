class Style < ApplicationRecord
  has_many :features, dependent: :destroy

  attr_accessor :colors
  BASE_URL = 'https://api.mapbox.com/styles/v1/'
  USER_ID = 'mjones1818'
  @@colors = {
    land: {
      name: 'Existing',
      code: '#E3B505'
    },
    water: {
      name: 'Existing',
      code: '#044B7F'
    },
    roads: {
      name: 'Exitsting',
      code: '#610345'
    },
    unassigned1: {
      name: 'Exitsting',
      code: '#610345'
    },
    unassigned2: {
      name: 'Exitsting',
      code: '#610345'
    }
  }

  def self.rcm(name='RCM')
    # Style.get_styles
    style = Style.last
    # style.delete_style
    result = style.new_style
    style.delete_style
    # Color.get_colors
    result
  end

  def self.save_style(style_id=Style.last.style_id)
    style = Style.find_by(style_id: style_id)
    
    result = style.new_style(false)
    result
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
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style_id}?access_token=#{ENV['API_KEY']}&sortby=created")
    response = Net::HTTP.get_response(uri)
    json_response = JSON.parse(response.body)
  end

  def prepare_for_update(name=nil)
    new_colors = Color.new
    # @@colors = new_colors.assign_colors
    @@colors = new_colors.assign_colors_from_db
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
    # byebug
    if name
      style_object['name'] = "RCM - #{colors[:land][:name]}, #{colors[:water][:name]}, #{colors[:roads][:name]}"
    else
      style_object['name'] = "#{style_object['name']} copy"
      return style_object
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

  def new_style(original=true)
    uri = URI.parse("#{BASE_URL+USER_ID}/?access_token=#{ENV['API_KEY']}")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request.body = ""
    request.body << self.prepare_for_update(original)
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

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
    does_style_exist = false
    !!Style.find_by(style_id: style['id']) ? does_style_exist = true : does_style_exist = false
    new_style = Style.find_or_create_by(style_id: style['id'])
    new_style[:name] = style['name']
    new_style[:style_id] = style['id']
    updated_object = new_style.get_style_data(style['id'])
    new_style[:style_object] = updated_object


    if !does_style_exist
      updated_object['layers'].each do |layer|
        if layer['id'] == 'land'
          land = new_style.features.build(name: 'land')
          color = Color.new(name:@@colors[:land][:name], code:layer['paint']['background-color'])
          land.color = color
          land.save
        elsif layer['id'] == 'water'
          water = new_style.features.build(name: 'water')
          color = Color.new(name:@@colors[:water][:name], code:layer['paint']['fill-color'])
          water.color = color
          water.save
        else
          roads = new_style.features.build(name: 'roads')
          color = Color.new(name:@@colors[:roads][:name], code: layer['paint']['line-color'])
          roads.color = color
          roads.save
        end
      end
      unassigned1 = new_style.features.build(name: 'unassigned1')
      color = Color.new(name:@@colors[:unassigned1][:name], code:@@colors[:unassigned1][:code])
      unassigned1.color = color
      unassigned1.save

      unassigned2 = new_style.features.build(name: 'unassigned2')
      color = Color.new(name:@@colors[:unassigned2][:name], code:@@colors[:unassigned2][:code])
      unassigned2.color = color
      unassigned2.save
    end
    new_style.save
    new_style
  end

  def get_map(dimensions='1000X1000')
    lon = self.style_object['center'].first
    lat = self.style_object['center'][1]
    zoom = self.style_object['zoom']
    uri = URI.parse("#{BASE_URL+USER_ID}/#{style_id}/static/#{lon},#{lat},#{zoom},0,0/#{dimensions}?access_token=#{ENV['API_KEY']}")
    # response = Net::HTTP.get_response(uri)
    uri
  end
end
