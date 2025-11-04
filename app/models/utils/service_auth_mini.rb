# frozen_string_literal: true

module Utils
  class ServiceAuthMini < ServiceAuth
    validates_each :subnet do |record, attr, value|
      IPAddr.new(value)
    rescue IPAddr::InvalidAddressError
      record.errors.add(attr, "Is not a valid subnet")
    end
    def check(request, _params)
      if subnet.present?
        ip = IPAddr.new(request.remote_ip)
        sn = IPAddr.new(subnet)
        return false unless sn.include? ip
      end
      return false if user.present? && params['app'] != user

      true
    end
  end
end
