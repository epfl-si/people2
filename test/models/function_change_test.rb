# frozen_string_literal: true

require 'test_helper'
require 'ostruct'

class FunctionChangeTest < ActiveSupport::TestCase
  class FunctionChangeTest < ActiveSupport::TestCase
    test "sciper extracts from accreditation_id" do
      fc = FunctionChange.new(accreditation_id: "123456:UNIT1")
      assert_equal "123456", fc.sciper
    end

    test "unit_id extracts from accreditation_id" do
      fc = FunctionChange.new(accreditation_id: "123456:UNIT1")
      assert_equal "UNIT1", fc.unit_id
    end

    test "accreditation raises if accreditation_id is missing" do
      fc = FunctionChange.new
      assert_raises(RuntimeError, "Accreditation not provided") { fc.accreditation }
    end

    test "selected_accreditors returns correct subset from available" do
      fc = FunctionChange.new(
        accreditation_id: "123456:UNIT1",
        accreditor_scipers: %w[111 222]
      )

      fake_accreditors = [
        OpenStruct.new(sciper: "111"),
        OpenStruct.new(sciper: "222"),
        OpenStruct.new(sciper: "333")
      ]

      fake_accreditation = OpenStruct.new(accreditors: fake_accreditors)

      # Stub de la méthode `accreditation`
      fc.define_singleton_method(:accreditation) { fake_accreditation }

      selected = fc.selected_accreditors
      assert_equal 2, selected.size
      assert selected.key?("111")
      assert selected.key?("222")
      refute selected.key?("333")
    end

    test "accreditors_correspondence adds error if none match" do
      fc = FunctionChange.new(
        accreditation_id: "123456:UNIT1",
        accreditor_scipers: ["999"],
        requested_by: "test",
        function: "Boss",
        reason: "Needed"
      )

      fake_accreditors = [
        OpenStruct.new(sciper: "111"),
        OpenStruct.new(sciper: "222")
      ]
      fake_accreditation = OpenStruct.new(accreditors: fake_accreditors)
      fc.define_singleton_method(:accreditation) { fake_accreditation }

      fc.valid?

      assert_includes fc.errors[:accreditor_scipers], "includes invalid data"
    end
  end
end
