# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
class SpywareUploadJob < ApplicationJob
  queue_as :default

  # count == 0 => upload all pending logs
  # purge == 0 => do not purge local database
  # purge == N > 0 => purge all logs older than N days
  def perform(batch_size: 10, count: 0, purge: 0)
    raise "batch_size should be a positive integer" unless batch_size.is_a?(Numeric) && batch_size.positive?
    raise "count should be a non negative number" unless count.is_a?(Numeric) && count >= 0
    raise "purge should be a non negative number" unless purge.is_a?(Numeric) && purge >= 0

    # TODO: in production there are actually three SPYWARE_URLs we should use in a round-robin fashion.
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
    # TODO: move the ca cert files out of the app code and mount them from a config map instead
    @http_opts = {
      use_ssl: @uri.scheme == "https",
      verify_mode: OpenSSL::SSL::VERIFY_PEER,
      ca_file: Rails.root.join("config/opdo_ca_#{Rails.env}.crt").to_s
    }

    count_before = Work::SpywareLog.uploadanda.count
    count = count_before if count.zero?
    [count, count_before].min

    Work::SpywareLog.uploadanda.limit(count).in_batches(of: batch_size).each do |batch|
      Rails.logger.debug batch.map(&:to_opdo).to_json
      # res = upload_batch_single_request(batch)
      res = upload_batch(batch)
      break unless res
    end

    return unless purge.positive?

    pc = Work::SpywareLog.uploaded.where('created_at < ?', purge.days.ago).count
    Work::SpywareLog.uploaded.where('created_at < ?', purge.days.ago).in_batches(of: 1000).delete_all
    # TODO: Yabeda currently does not from background jobs. I keep the statements in
    # case we find-out how to make it work. I think there is not communication
    # with yabeda-prometheus because it is a separate process or even that,
    # since there is no puma process it is just not started. I guess, the way
    # of fixing this is at least to have the multiprocess_files_dir where
    # yabeda-prometheus write files in a directory shared between pods but it
    # is not enough or at least I didn't try that hard enough.
    Yabeda.people.opdo_purged.increment({}, by: pc)
  end

  def upload_batch(logs)
    return false if logs.blank?

    done = []
    errcount = 0
    begin
      Net::HTTP.start(@uri.host, @uri.port, @http_opts) do |http|
        logs.each do |line|
          done << line.id
          # request object are designed to be single use
          request = Net::HTTP::Post.new("#{@uri.path}/_doc", @headers)
          request.body = line.to_opdo.to_json
          response = http.request(request)
          if response.is_a?(Net::HTTPSuccess)
            done << line.id
          else
            errcount += 1
          end
        end
        request = Net::HTTP::Head.new("#{@uri.path}/_doc", @headers)
        http.request(request)
      end
    rescue StandardError
      raise "something did not work while uploading spyware logs to OPDo server"
    ensure
      unless done.empty?
        Work::SpywareLog.where(id: done).update_all(uploaded_at: Time.zone.now)
        Yabeda.people.opdo_uploads.increment({}, by: done.count)
      end
    end
    Yabeda.people.opdo_upload_errors.increment({}, by: errcount) if errcount.positive?
    errcount.zero?
  end

  # This one upload the full batch in a single HTTP request but the format is
  # soo absurd (because it is meant for streaming multiple requests)
  # that I don't really see the point of doing it.
  def upload_batch_single_request(logs)
    return false if logs.blank?

    # The payload must be a string with two lines foreach record
    # where the first line express the action (in our case {create: {}}), the
    # second the argument for the action (in our case the document)
    # data = logs.map { |l| [{ create: {} }, { doc: l.to_opdo }] }.flatten.map(&:to_json).join("\n") + "\n"
    data = logs.map { |l| [{ create: {} }, { doc: l.to_opdo }] }.flatten.map(&:to_json).map { |l| "#{l}\n" }.join
    Net::HTTP.start(@uri.host, @uri.port, @http_opts) do |http|
      request = Net::HTTP::Post.new("#{@uri.path}/_bulk", @headers)
      request.body = data
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        Work::SpywareLog.where(id: logs.map(&:id)).update_all(uploaded_at: Time.zone.now)
        true
      else
        Rails.logger.error response.body
        false
      end
    end
  end
end
# rubocop:enable Rails/SkipsModelValidations
