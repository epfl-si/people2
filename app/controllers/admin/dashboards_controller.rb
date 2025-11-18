# frozen_string_literal: true

module Admin
  class DashboardsController < BaseController
    # This way, one day we can make this user-configurable. Reload for changes to be effective.
    PANELS = [
      { name: "adoplatest", enabled: true, gridcol: ["auto", 3], gridrow: ["auto", 2] },
      { name: "adopcount", enabled: true, gridcol: ["auto", 1], gridrow: ["auto", 1] },
      { name: "scipercount", enabled: true, period: 1_800, gridcol: ["auto", 1], gridrow: ["auto", 1] },
      { name: "jobs", enabled: true, period: 30, gridcol: ["auto", 2], gridrow: ["auto", 1] },
      { name: "opdo", enabled: true, period: 600, gridcol: ["auto", 2], gridrow: ["auto", 1] },
      { name: "reqheads", enabled: true, period: 600, gridcol: ["auto", 2], gridrow: ["auto", 2] },
      { name: "appconfig", enabled: true, period: 600, gridcol: ["auto", 2], gridrow: ["auto", 2] }
    ].map { |h| [h[:name], OpenStruct.new({ period: 60 }.merge(h))] }.to_h.freeze

    def index
      @panels = PANELS.values.select(&:enabled)
    end

    def show
      @panel = PANELS[params[:id]]
      raise ActionController::RoutingError if @panel.blank?

      @interval = 60 # seconds

      send(@panel.name)
    end

    def adopcount
      @ado_tot = Adoption.count
      @ado_acc = Adoption.accepted.count
      @ado_orp = @ado_tot - @ado_acc
    end

    def adoplatest
      @adoptions = Adoption.accepted.order("updated_at DESC").limit(10)
    end

    def appconfig
      @appconfig = {}
      %i[
        version superusers app_hostname enable_direct_uploads hide_teacher_accreds
        force_audience api_v0_wsgetpeople_cache name_change_request_email
        enable_adoption legacy_base_url legacy_pages_cache legacy_import_job_log_path
        skip_api_access_control
      ].each do |key|
        @appconfig[key.to_s] = Rails.configuration.send(key)
      end
      %i[epflapi].each do |g|
        c = Rails.application.config_for(g)
        c.each do |k, v|
          next if k =~ /key|pass|token/

          @appconfig["#{g}.#{k}"] = v
        end
      end
    end

    def opdo
      @counts = [
        { label: "Total log lines in the DB", value: Work::SpywareLog.count },
        { label: "Already uploaded log lines", value: Work::SpywareLog.uploaded.count },
        { label: "To be uploaded log lines", value: Work::SpywareLog.uploadanda.count }
      ].map { |h| OpenStruct.new(h) }
    end

    def jobs
      t = SolidQueue::Job.count
      f = SolidQueue::FailedExecution.count
      @counts = [
        { label: "Total number of Jobs", value: t },
        { label: "Failed", value: f },
        { label: "Done", value: t - f },
        { label: "Recurring", value: SolidQueue::RecurringTask.count }
      ].map { |h| OpenStruct.new(h) }
    end

    def reqheads
      @hh = {}
      request.headers.each do |k, v|
        next unless k =~ /^(REQUEST|SERVER|HTTP)_/

        @hh[k] = v.to_s
      end
      @ip = request.remote_ip
    end

    def scipercount
      @interval = 1_800 # this is essentially constant => no need to reload often
      @peo_tot = Work::Sciper.count
      @peo_nop = Work::Sciper.noprofile.count
      @peo_yes = Work::Sciper.migrated.count
      @peo_mig = Work::Sciper.migranda.count
    end
  end
end
