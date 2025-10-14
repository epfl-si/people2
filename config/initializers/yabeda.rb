# frozen_string_literal: true

require "prometheus/client/support/puma"

Prometheus::Client.configuration.pid_provider = Prometheus::Client::Support::Puma.method(:worker_pid_provider)

Yabeda.configure do
  group :people do
    # counter   :bells_rang_count, comment: "Total number of bells being rang", tags: %i[bell_size]
    # gauge     :whistles_active,  comment: "Number of whistles ready to whistle"
    # histogram :whistle_runtime do
    #   comment "How long whistles are being active"
    #   unit :seconds
    # end
    # summary :bells_ringing_duration, unit: :seconds, comment: "How long bells are ringing"
    gauge :adoptions_count, unit: :integer, comment: "Number of Adoptions"
    counter :wsgetpeople_calls, unit: :integer, comment: "Numbers of requests for wsgetpeople"
    counter :opdo_upload_errors, unit: :integer,
                                 comment: "Number of failed upload attempts of spyware logs to the OPDo server"
    counter :opdo_uploads, unit: :integer,
                           comment: "Number of spyware logs that have been succesfully uploaded to the OPDo server"
  end
end
Yabeda::ActiveJob.install!
Yabeda.configure!
