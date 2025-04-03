# frozen_string_literal: true

require "test_helper"

class PositionTest < ActiveSupport::TestCase
  test "initialize maps labels and fallbacks correctly" do
    h = {
      "id" => 42,
      "labelen" => "Researcher",
      "labelfr" => "Chercheur",
      "labelinclusive" => "Chargé·e de recherche",
      "labelxx" => "Chargé X"
    }

    pos = Position.new(h)

    assert_equal 42, pos.id
    assert_equal "Researcher", pos.label_en
    assert_equal "Chercheur", pos.label_frm
    assert_equal "Chargé·e de recherche", pos.label_fri
    assert_equal "Chargé X", pos.label_frf
    assert_equal "Researcher", pos.label_it
    assert_equal "Researcher", pos.label_de
  end

  test "fallback to labelfr when inclusive labels are missing" do
    h = {
      "labelfr" => "Assistant",
      "labelen" => "Assistant"
    }

    pos = Position.new(h)

    assert_equal "Assistant", pos.label_fri
    assert_equal "Assistant", pos.label_frf
  end

  test "match_legacy_filter? returns true if regex matches label_frm" do
    pos = Position.new({ "labelfr" => "Chargé de cours" })
    assert pos.match_legacy_filter?(/cours/)
    refute pos.match_legacy_filter?(/doctorat/)
  end

  test "possibly_teacher? matches on known patterns" do
    pos = Position.new({ "labelfr" => "Professeur ordinaire" })
    assert pos.possibly_teacher?

    pos2 = Position.new({ "labelfr" => "Technicien" })
    refute pos2.possibly_teacher?
  end

  test "enseignant? matches ENS_RE patterns" do
    pos = Position.new({ "labelfr" => "Professeur honoraire" })
    assert pos.enseignant?

    pos2 = Position.new({ "labelfr" => "Chargé de recherche" })
    refute pos2.enseignant?
  end

  test "dump and load produces a valid Position object" do
    original = Position.new({
                              "id" => 1,
                              "labelen" => "Lecturer",
                              "labelfr" => "Chargé de cours",
                              "labelinclusive" => "Chargé·e de cours",
                              "labelxx" => "CoursX"
                            })

    dumped = Position.dump(original)
    reloaded = Position.load(dumped)

    assert_instance_of Position, reloaded
    assert_equal original.label_en, reloaded.label_en
    assert_equal original.label_frm, reloaded.label_frm
    assert_equal original.label_fri, reloaded.label_fri
    assert_equal original.label_frf, reloaded.label_frf
    assert_equal original.id, reloaded.id
  end
end
