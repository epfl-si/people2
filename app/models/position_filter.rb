# frozen_string_literal: true

class PositionFilter
  attr_reader :filter

  def initialize(f)
    @filter = f.gsub("*", ".*").split(/ or /).join("|")
  end

  def re
    unless defined?(@re)
      begin
        @re = Regexp.new(filter)
      rescue StandardError
        @re = nil
      end
    end
    @re
  end

  # TODO: implement filter validation
  def valid?
    re.present?
  end

  def match?(position)
    (position =~ re).present?
  end
end
