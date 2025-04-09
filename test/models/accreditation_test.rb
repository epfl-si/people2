# frozen_string_literal: true

require "test_helper"

class AccreditationTest < ActiveSupport::TestCase
  def setup
    @stub_data = {
      'persid' => '116080',
      'unit' => {
        'id' => 14_214,
        'name' => 'Test Unit',
        'labelfr' => 'Test Unité',
        'labelen' => 'Test Unit EN'
      },
      'status' => {
        'id' => 5,
        'labelfr' => 'Professeur',
        'labelen' => 'Professor'
      },
      'order' => 1,
      'position' => {
        'labelen' => 'Professeur',
        'labelfr' => 'Professor'
      }
    }
  end

  def stub_api_accreds_getter(response)
    original_api_accreds = APIAccredsGetter.method(:call)
    original_authorisation = Authorisation.method(:property_for_sciper)
    original_unit_getter = APIUnitGetter.method(:call)

    APIAccredsGetter.define_singleton_method(:call) { |_| response }
    Authorisation.define_singleton_method(:property_for_sciper) { |_sciper, _property| [] }
    APIUnitGetter.define_singleton_method(:call) { |_args| [] }

    yield
  ensure
    APIAccredsGetter.define_singleton_method(:call, original_api_accreds)
    Authorisation.define_singleton_method(:property_for_sciper, original_authorisation)
    APIUnitGetter.define_singleton_method(:call, original_unit_getter)
  end

  test "find returns an Accreditation with correct id" do
    stub_api_accreds_getter(@stub_data.deep_dup) do
      accred = Accreditation.find("116080:14214")
      assert_equal "116080:14214", accred.id
      assert_instance_of Accreditation, accred
    end
  end

  test "for_sciper returns a list of Accreditations" do
    stub_api_accreds_getter([@stub_data.deep_dup]) do
      accreds = Accreditation.for_sciper("116080")
      assert_instance_of Array, accreds
      assert(accreds.all? { |a| a.is_a?(Accreditation) })
    end
  end

  test "for_profile attaches prefs to accreditations" do
    stub_api_accreds_getter([@stub_data.deep_dup]) do
      profile = Profile.new(sciper: "116080")

      fake_accreds = Class.new do
        def new(attrs = {})
          OpenStruct.new(attrs.merge(visible?: true, hidden_addr?: false, new_record?: true, save: true))
        end

        def empty?
          true
        end

        def index_by
          {}
        end

        def where(*)
          self
        end
      end.new

      profile.define_singleton_method(:accreds) { fake_accreds }

      accreds = Accreditation.for_profile(profile)
      assert_instance_of Array, accreds
      assert(accreds.all? { |a| a.prefs.present? })
    end
  end

  test "student? returns true if status_id between 4 and 6" do
    accred = Accreditation.new(@stub_data.deep_dup)
    assert accred.student?
  end

  test "student? returns false if status_id outside 4 and 6" do
    data = @stub_data.deep_dup
    data['status']['id'] = 8
    accred = Accreditation.new(data)
    assert_not accred.student?
  end

  test "order returns prefs position when prefs present" do
    accred = Accreditation.new(@stub_data.deep_dup)
    prefs = OpenStruct.new(position: 2)
    accred.prefs = prefs

    assert_equal [2, accred.accred_order], accred.order
  end

  test "order returns accred_order when prefs absent" do
    accred = Accreditation.new(@stub_data.deep_dup)
    assert_equal [accred.accred_order, accred.accred_order], accred.order
  end

  test "hidden? returns inverse of visible?" do
    accred = Accreditation.new(@stub_data.deep_dup)
    accred.define_singleton_method(:visible?) { true }
    assert_not accred.hidden?

    accred = Accreditation.new(@stub_data.deep_dup)
    accred.define_singleton_method(:visible?) { false }
    assert accred.hidden?
  end

  test "hidden_addr? returns true if prefs hidden_addr" do
    accred = Accreditation.new(@stub_data.deep_dup)
    prefs = OpenStruct.new(hidden_addr?: true)
    accred.prefs = prefs

    assert accred.hidden_addr?
  end

  test "hidden_addr? returns false if no prefs" do
    accred = Accreditation.new(@stub_data.deep_dup)
    accred.prefs = nil

    assert_not accred.hidden_addr?
  end

  test "possibly_teacher? matches known patterns" do
    accred = Accreditation.new(@stub_data.deep_dup)
    position_mock = OpenStruct.new(possibly_teacher?: true)
    accred.define_singleton_method(:position) { position_mock }

    assert accred.possibly_teacher?
  end

  test "visible? combines botweb, prefs and position checks" do
    accred = Accreditation.new(@stub_data.deep_dup)
    accred.define_singleton_method(:botweb?) { true }
    accred.prefs = OpenStruct.new(visible?: true)
    accred.define_singleton_method(:position) { OpenStruct.new(enseignant?: false) }

    assert accred.visible?
  end
end
