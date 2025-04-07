# frozen_string_literal: true

require "test_helper"

class StructureTest < ActiveSupport::TestCase
  def sample_data
    [
      { "title" => "Professors", "filter" => "Professeur" },
      { "title" => "Students", "filter" => "Student" }
    ]
  end

  class FakePerson
    def initialize(matches:)
      @matches = matches
    end

    def match_position_filter?(filter)
      @matches.include?(filter.filter)
    end

    def select_positions!(_filter)
      # TODO: add better verification
    end
  end

  class FakeFilter
    attr_reader :filter

    def initialize(filter)
      @filter = filter
    end

    def valid?
      !@filter.nil? && @filter != "invalid"
    end

    def catch_all?
      false
    end
  end

  setup do
    @structure = Structure.new(label: "test_structure", data: sample_data)

    @original_position_filter_new = PositionFilter.method(:new)

    PositionFilter.define_singleton_method(:new) do |arg|
      FakeFilter.new(arg)
    end
  end

  teardown do
    PositionFilter.define_singleton_method(:new, @original_position_filter_new)
  end

  test "sections parses data into valid sections" do
    sections = @structure.sections
    assert_equal 2, sections.count
    assert_equal "Professors", sections.first.title
  end

  test "check_sections_count_match adds error if mismatch" do
    structure = Structure.new(label: "invalid", data: [{ "title" => "Professors", "filter" => "Professeur" }])
    structure.data << { "invalid" => "entry" }

    begin
      original = PositionFilter.method(:new)
      PositionFilter.define_singleton_method(:new) { |arg| FakeFilter.new(arg) }

      structure.valid?
      assert_includes structure.errors[:data], "sections count does not match data entries"
    ensure
      PositionFilter.define_singleton_method(:new, original)
    end
  end

  test "store adds person to the correct section" do
    person = FakePerson.new(matches: ["Professeur"])
    assert @structure.store(person)
    assert_equal 1, @structure.sections.first.items.size
  end

  test "store! modifies person and adds to section" do
    person = FakePerson.new(matches: ["Professeur"])
    assert @structure.store!(person)
    assert_equal 1, @structure.sections.first.items.size
  end

  test "load returns structure by label" do
    Structure.create!(label: "test_label", data: sample_data)
    loaded = Structure.load("test_label")
    assert_not_nil loaded
    assert_equal "test_label", loaded.label
  end
end
