# frozen_string_literal: true

module Admin
  class DashboardsController < BaseController
    # This way, one day we can make this user-configurable
    PANELS = [
      { name: "adoplatest", enabled: true, gridcol: ["auto", 3], gridrow: ["auto", 3] },
      { name: "adopcount", enabled: true, gridcol: ["auto", 1], gridrow: ["auto", 1] },
      { name: "scipercount", enabled: true, period: 1_800, gridcol: ["auto", 1], gridrow: ["auto", 1] },
      { name: "jobs", enabled: true, period: 30, gridcol: ["auto", 1], gridrow: ["auto", 1] }
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

    def scipercount
      @interval = 1_800 # this is essentially constant => no need to reload often
      @peo_tot = Work::Sciper.count
      @peo_nop = Work::Sciper.noprofile.count
      @peo_yes = Work::Sciper.migrated.count
      @peo_mig = Work::Sciper.migranda.count
    end
  end
end
