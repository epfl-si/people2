# frozen_string_literal: true

# Legacy position filters have three forms:
#   1. a list of positions (tokens) to be ORed: "aaa or bbb or ccc"
#   2. a list of positions to be ANDed: "aaa and bbb and ccc"
#   3. anything else that will be interpreted as a SINGLE position
# tokens can be negated prefixing them with an exclamation mark !
# although this makes sense probably only for AND lists
# Example:
# aaa and !bbb and ccc

class PositionFilter
  OKTOKEN = "!?[-^$\/'.*&\s[:alnum:]]+"
  LEGACY_FILTER_RE = /^(#{OKTOKEN})(\s(or|and)\s(#{OKTOKEN}))*$/i

  def initialize(rule)
    # TODO: more strict validation ?
    @valid = rule.encode(Encoding::ASCII_8BIT, replace: '') =~ LEGACY_FILTER_RE

    if rule.strip == "*"
      @catch_all = true
      return
    end
    @catch_all = false

    if rule.include?(" and ")
      @all = true
      sep = " and "
    else
      @all = false
      sep = " or "
    end
    @tokens = rule.split(sep).map do |t|
      neg = t.start_with?("!")
      t = t[1..] if neg
      # The * in filter token is shell glob style but must be an exact match otherwise
      re = Regexp.new("^#{t.gsub('*', '.*')}$", 'i')
      OpenStruct.new(
        neg: neg,
        re: re
      )
    end
  end

  def valid?
    !@valid.nil?
  end

  def catch_all?
    @catch_all
  end

  def match?(str)
    return true if @catch_all
    return @tokens.all? { |t| token_match(t, str) } if @all

    @tokens.any? { |t| token_match(t, str) }
  end

  private

  def token_match(t, str)
    if t.neg
      return true unless str.match?(t.re)
    elsif str.match?(t.re)
      return true
    end
    false
  end
end
