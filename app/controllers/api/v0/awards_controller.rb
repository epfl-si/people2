# frozen_string_literal: true

module API
  module V0
    class AwardsController < LegacyBaseController
      # get cgi-bin/prof_awards -> /api/v0/prof_awards
      def index
        cid = APIConfigGetter.call(res: "rights")["AAR.report.control"]["id"]
        aa = APIAuthGetter.call(authid: cid, type: 'right')
        scipers = aa.map { |a| a["persid"] }.sort.uniq
        @awards = Award.joins(:profile).where(profile: { sciper: scipers })
        respond_to do |format|
          format.json
          format.csv do
            filename = ['awards', Time.zone.today].join('_')
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = "attachment; filename=#{filename}.csv"
          end
        end
      end
    end
  end
end
