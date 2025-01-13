# frozen_string_literal: true

# TODO: consider using ActiveResource + cached_resource

class APIBaseGetter < ApplicationService
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
    "v1/#{@resource}"
  end

  def genreq
    Rails.logger.debug "epfl api genreq"
    cfg = Rails.application.config_for(:epflapi)
    req = Net::HTTP::Get.new(@url)
    req.basic_auth cfg.username, cfg.password
    req
  end

  def dofetch
    body = fetch_http
    return nil unless body

    data = JSON.parse(body)
    return data unless data.key?(@resource) # && data.key?("count")

    data = data[@resource]
    return data unless @single

    case data.count
    when 0
      nil
    when 1
      data.first
    else
      raise "epfl_api returns multiple elements when a single one is expected url=#{@url}"
    end
  end
end
