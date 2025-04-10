# frozen_string_literal: true

require "test_helper"

class AccreditorTest < ActiveSupport::TestCase
  def setup
    @stub_data = [
      {
        "person" => {
          "firstname" => "John",
          "lastname" => "Doe",
          "firstnameusual" => "Johnny",
          "lastnameusual" => "D."
        }
      }
    ]

    @single_stub_person = @stub_data.first["person"]
  end

  test "for_sciper returns an array of Accreditors" do
    stub_data = [
      {
        "person" => {
          "firstname" => "John",
          "lastname" => "Doe",
          "firstnameusual" => "Johnny",
          "lastnameusual" => "D."
        }
      }
    ]

    original_method = APIAuthGetter.method(:call)
    APIAuthGetter.define_singleton_method(:call) do |*|
      stub_data.deep_dup
    end

    accreditors = Accreditor.for_sciper("116080")

    assert_instance_of Array, accreditors
    assert(accreditors.all? { |a| a.is_a?(Accreditor) })
  ensure
    APIAuthGetter.define_singleton_method(:call, original_method)
  end

  test "for_sciper returns nil if API returns blank" do
    original_method = APIAuthGetter.method(:call)
    APIAuthGetter.define_singleton_method(:call) do |*|
      []
    end

    result = Accreditor.for_sciper("116080")
    assert_nil result
  ensure
    APIAuthGetter.define_singleton_method(:call, original_method)
  end

  test "display uses firstnameusual and lastnameusual if present" do
    accreditor = Accreditor.new(@single_stub_person)

    assert_equal "Johnny D.", accreditor.display
  end

  test "display falls back to firstname and lastname if usual names are blank" do
    data = {
      "firstname" => "John",
      "lastname" => "Doe",
      "firstnameusual" => nil,
      "lastnameusual" => nil
    }
    accreditor = Accreditor.new(data)

    assert_equal "John Doe", accreditor.display
  end
end
