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

  def phds_as_director
    @phds_as_director ||= Phd.where(director_sciper: sciper)
  end

  def phds_as_codirector
    @phds_as_codirector ||= Phd.where(codirector_sciper: sciper)
  end

  def phds
    @phds ||= phds_as_director + phds_as_codirector
  end

  def current_phds
    # Phd.current.where(director_sciper: sciper)
    y = Time.zone.now.year
    phds.select { |c| c.year == y }
  end

  def past_phds
    # Phd.past.where(director_sciper: sciper)
    y = Time.zone.now.year
    phds.select { |c| c.year < y }
  end

  def past_phds_as_director
    y = Time.zone.now.year
    phds_as_director.select { |c| c.year < y }
  end

  def past_phds_as_codirector
    y = Time.zone.now.year
    phds_as_codirector.select { |c| c.year < y }
  end
end
