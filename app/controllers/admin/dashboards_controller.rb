# frozen_string_literal: true

module Admin
  class DashboardsController < BaseController
    def index
      @panels = %w[adopcount adoplatest]
    end

    def show
      @panel = params[:id]
      raise ActionController::RoutingError unless respond_to?(@panel)

      send(@panel)
    end

    def adopcount
      @ado_tot = Adoption.count
      @ado_acc = Adoption.accepted.count
      @ado_orp = @ado_tot - @ado_acc
      @peo_tot = Work::Sciper.count
      @peo_nop = Work::Sciper.noprofile.count
      @peo_yes = Work::Sciper.migrated.count
      @peo_mig = Work::Sciper.migranda.count
    end

    def adoplatest
      @adoptions = Adoption.accepted.order("updated_at DESC").limit(10)
    end
  end
end
