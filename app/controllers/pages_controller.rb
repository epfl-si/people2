# frozen_string_literal: true

class PagesController < ApplicationController
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  allow_unauthenticated_access only: [:homepage]

  layout 'public'

  def homepage; end

  # rescue_from ActionPolicy::Unauthorized do |_exception|
  #   redirect_to "/401"
  # end
  DESCS = {
    "116080" => "profile with forced french language and some bio box",
    "243371" => "very little data but usual name different from official one",
    "121769" => "nothing special but its me ;)",
    "229105" => "a professor with a lot of affiliations",
    "110635" => "a standard prof",
    "126003" => "a prof with various affiliations and links",
    "107931" => "a teacher",
    "363674" => "a student",
    "173563" => "A person whose profile should be created the first edit",
    "185853" => "an external for which there should be no people page",
    "195348" => "Another external for which there should be no people page",
    "123456" => "a (fake) existing person with redirect applied",
  }.freeze
  EXTRAPROFILES = [
    {
      name: "Loïc",
      sciper: "185853",
      desc: "an external for which there should be no people page",
    },
    {
      name: "Herve",
      sciper: "195348",
      desc: "Another external for which there should be no people page",
    },
    {
      name: "Ciccio",
      sciper: "999999",
      desc: "a (fake) existing person that does not have to appear and must be redirected",
    },
    {
      name: "Mr Long Name",
      sciper: "363247",
      desc: "A student with an incredibly long name"
    },
    {
      name: "Giustino",
      sciper: "400868",
      desc: "a student who is also class delegate",
    }
  ].freeze
  def devindex
    @data = EXTRAPROFILES.map { |d| OpenStruct.new(d) }
    scipers = @data.map(&:sciper).uniq
    @adoptions =
      Adoption.where(sciper: scipers)
              .select { |a| allowed_to?(:update?, a) }.index_by(&:sciper)
  end
end
