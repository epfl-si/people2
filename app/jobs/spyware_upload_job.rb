# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class SpywareUploadJob < ApplicationJob
  queue_as :default

  # batch_size
  def perform(batch_size: 10, all: false)
    raise "batch_size should be a positive integer" unless batch_size.is_a?(Numeric) && batch_size.positive?

    server_url = ENV.fetch('SPYWARE_URL', nil)
    server_key = ENV.fetch('SPYWARE_KEY', nil)
    unless server_url.present? && server_key.present?
      raise "no OPDO storage server url or credential provided. Please ensure both SPYWARE_URL and SPYWARE_KEY are set."
    end

    @uri = URI.parse(server_url)
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "ApiKey #{server_key}"
    }

    if all
      while do_perform(batch_size)
      end
    else
      do_perform(batch_size)
    end
  end

  def do_perform(batch_size)
    logs = Work::SpywareLog.uploadanda.first(batch_size)
    return false if logs.blank?

    done = []
    begin
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == "https",
                                            verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        logs.each do |line|
          done << line.id
          # request object are designed to be single use
          request = Net::HTTP::Post.new(@uri, @headers)
          request.body = line.to_opdo.to_json
          response = http.request(request)
          done << line.id if response.is_a?(Net::HTTPSuccess)
        end
      end
    rescue StandardError
      raise "something did not work while uploading spyware logs to OPDo server"
    ensure
      Work::SpywareLog.where(id: done).update_all(uploaded_at: Time.zone.now) unless done.empty?
    end
    done.count == logs.count
  end
end
# rubocop:enable Rails/SkipsModelValidations
