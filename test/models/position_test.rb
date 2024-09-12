# frozen_string_literal: true

require 'test_helper'

class PositionTest < Minitest::Test
  def setup
    @position_data = {
      'id' => 1,
      'labelen' => 'Professor',
      'labelfr' => 'Professeur',
      'labelinclusive' => 'Professeur inclusif',
      'labelxx' => 'Professeur XX'
    }
    @position = Position.new(@position_data)
  end

  def test_initialization
    assert_equal 1, @position.id
    assert_equal 'Professor', @position.label_en
    assert_equal 'Professeur', @position.label_frm
    assert_equal 'Professeur inclusif', @position.label_fri
    assert_equal 'Professeur XX', @position.label_frf
  end

  def test_initialization_with_missing_inclusive_label
    position_data = {
      'id' => 2,
      'labelen' => 'Teacher',
      'labelfr' => 'Enseignant'
    }
    position = Position.new(position_data)
    assert_equal 2, position.id
    assert_equal 'Teacher', position.label_en
    assert_equal 'Enseignant', position.label_frm
    assert_equal 'Enseignant', position.label_fri
    assert_equal 'Enseignant', position.label_frf
  end

  def test_load
    payload = YAML.dump(@position_data)
    loaded_position = Position.load(payload)

    assert_equal @position.id, loaded_position.id
    assert_equal @position.label_en, loaded_position.label_en
    assert_equal @position.label_frm, loaded_position.label_frm
    assert_equal @position.label_fri, loaded_position.label_fri
    assert_equal @position.label_frf, loaded_position.label_frf
  end

  def test_dump
    dumped_data = Position.dump(@position)
    expected_yaml = YAML.dump({
                                "id" => 1,
                                "labelen" => 'Professor',
                                "labelfr" => 'Professeur',
                                "labelinclusive" => 'Professeur inclusif',
                                "labelxx" => 'Professeur XX'
                              })

    assert_equal expected_yaml, dumped_data
  end

  def test_possibly_teacher_with_professor_label
    assert @position.possibly_teacher?, "Position with 'Professeur' should be recognized as a teacher"
  end

  def test_possibly_teacher_with_non_teacher_label
    non_teacher_position = Position.new({
                                          'id' => 3,
                                          'labelen' => 'Assistant',
                                          'labelfr' => 'Assistant'
                                        })
    refute non_teacher_position.possibly_teacher?, "Position with 'Assistant' should not be recognized as a teacher"
  end

  def test_enseignant_with_honorary_professor_label
    honorary_position = Position.new({
                                       'id' => 4,
                                       'labelen' => 'Honorary Professor',
                                       'labelfr' => 'Professeur honoraire'
                                     })
    assert honorary_position.enseignant?, "Position with 'Professeur honoraire' should be recognized as a teacher"
  end

  def test_enseignant_with_non_teacher_label
    non_teacher_position = Position.new({
                                          'id' => 5,
                                          'labelen' => 'Researcher',
                                          'labelfr' => 'Chercheur'
                                        })
    refute non_teacher_position.enseignant?, "Position with 'Chercheur' should not be recognized as a teacher"
  end
end
