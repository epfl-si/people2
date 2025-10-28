# frozen_string_literal: true

# TODO: consider using ActiveResource + cached_resource

class APIBaseGetter < ApplicationService
  # IMPORTANT: do not set to more than 100 because it will be silently discarded
  PAGESIZE = 100
  # Before calling this, child class initializer
  # must have defined @resource and optionally @idname and @params
  # This class is a generic one for GET calls of the type
  # v1/resource/id      -> will retun a SINGLE object
  # or
  # v1/resource?params  -> will return a LIST of object
  # params can be either scalar or array
  # subclass can also define fix_PARAMNAME methods to preprocess the parameter
  def initialize(data = {})
    raise "Mandatory resource name is not defined" unless defined?(@resource) && @resource.present?

    @idname = :id unless defined?(@idname)
    @params ||= []
    @alias ||= {}
    @single = data.delete(:single) || false
    @noempty = true unless defined?(@allow_empty)
    @paginate = @params.include?(:pagesize)
    if @paginate
      @pagesize = data.delete(:pagesize) || PAGESIZE
      data.delete(:pageindex)
    end
    baseurl = data.delete(:baseurl) || Rails.application.config_for(:epflapi).backend_url
    id = @idname.present? ? data.delete(@idname).to_s : nil
    args = {}
    @params.each do |k|
      v = data.delete(k)
      next if v.nil?

      m = "fix_#{k}"
      vv = v.is_a?(Array) ? v : [v]
      ww = if respond_to?(m)
             vv.map { |u| send(m, u) }.join(",")
           else
             vv.join(",")
           end
      kk = (@alias[k] || k).to_s
      args[kk] = ww
    end
    if @noempty && id.nil? && args.empty?
      raise "No valid parameters provided for epfl api resource #{@resource}: data=#{data.inspect}"
    end

    if id.present?
      @single = true
      @url = URI.join(baseurl, "#{path}/#{id}")
    else
      @url = URI.join(baseurl, path)
      @url.query = URI.encode_www_form(args) unless args.empty?
    end
    super(data)
  end

  def path
    @resource.to_s
  end

  def genreq(url = @url)
    Rails.logger.debug "epfl api genreq"
    cfg = Rails.application.config_for(:epflapi)
    req = Net::HTTP::Get.new(url)
    req.basic_auth cfg.username, cfg.password
    req
  end

  def dofetch
    if @single
      dofetch_single
    elsif @paginate
      dofetch_paginated
    else
      dofetch_base
    end
  end

  def dofetch_base(url = @url)
    body = fetch_http(url)
    return nil unless body

    data = JSON.parse(body)
    return data unless data.key?(@resource)

    data[@resource]
  end

  def dofetch_paginated
    args = URI.decode_www_form(@url.query || "").to_h
    args[:pagesize] = @pagesize
    u = @url.dup
    page = 0
    data = []
    loop do
      args[:pageindex] = page
      page += 1
      u.query = URI.encode_www_form(args)
      page_data = dofetch_base(u)
      break if page_data.empty?

      data += page_data
      break if page_data.count < @pagesize
    end
    data
  end

  def dofetch_single
    data = dofetch_base
    return nil if data.nil?
    return data unless data.is_a? Array

    case data.count
    when 0
      nil
    when 1
      data.first
    else
      raise "epfl_api returns multiple elements when a single one is expected url=#{@url}"
    end
  end

  # The return from dofetch depends on @single too. Therefore it have to be included in the cache key
  def cache_key
    uid = Digest::MD5.hexdigest(url.to_s)
    "#{self.class.name.underscore}/#{@single ? 'S' : 'M'}/#{uid}"
  end
end
