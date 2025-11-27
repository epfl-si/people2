# frozen_string_literal: true

class ServiceAuthMini < ServiceAuth
  validates_each :subnet do |record, attr, content|
    subnet_string_to_list(content)
  rescue IPAddr::InvalidAddressError
    record.errors.add(attr, "Is not a list of valid subnet. Use comma separated ips in the xxx.xxx.xxx.xxx/yyy format")
  end

  def self.human_name
    "Legacy"
  end

  def self.description
    "Control based on source IP address and optionally the remote application name"
  end

  def self.subnet_string_to_list(content)
    content.split(/ *, */).map { |value| IPAddr.new(value) }
  end

  def ipsubnets
    @ipsubnets ||= ServiceAuthMini.subnet_string_to_list(subnet)
  end

  def check(request, params)
    if subnet.present?
      ip = IPAddr.new(request.remote_ip)
      return false unless ipsubnets.any? { |sn| sn.include? ip }
    end
    return false if user.present? && params['app'] != user

    Current.audience = audience
    true
  end

  def type_description
    "Basic check: only source ip address and eventually application name"
  end
end
