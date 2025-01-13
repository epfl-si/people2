# frozen_string_literal: true

class APIConfigGetter < APIBaseGetter
  def initialize(data = {})
    @resource = data.delete(:res)
    raise "Invalid Resource" unless %w[properties rights roles statuses].include?(@resource)

    @params = []

    super(data)
  end

  def path
    "v1/config/#{@resource}"
  end

  def dofetch
    r = super
    r.nil? ? r : r.index_by { |h| h['name'] }
  end
end
