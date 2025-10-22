# frozen_string_literal: true

class Teacher
  attr_reader :sciper, :display_name

  def initialize(person)
    @sciper = person.sciper
    @display_name = person.name.display
  end

  def courses
    # course_instances not used for the moment as it is too noisy and all the info is in edu
    # Course.where(
    #   acad: Course.current_academic_year
    # ).includes(
    #   :course_instances, :teacherships
    # ).where(
    #   teacherships: { sciper: sciper }
    # )
    Course.where(
      acad: Course.current_academic_year
    ).includes(
      :teacherships
    ).where(
      teacherships: { sciper: sciper }
    )
  end

  # only one AR request for all variants because the number of records is small
  def phds
    @phds ||= Phd.where(director_sciper: sciper).or(Phd.where(codirector_sciper: sciper))
  end

  def current_phds
    phds.select { |c| c.date.blank? }
  end

  def past_phds
    phds.select { |c| c.date.present? }
  end

  def past_phds_as_director
    phds.select { |c| c.date.present? && c.director_sciper == sciper }
  end

  def past_phds_as_codirector
    phds.select { |c| c.date.present? && c.codirector_sciper == sciper }
  end
end
