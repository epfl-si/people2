# Extended accred including address, phones, people preferences
class Legacy::Affiliation < Legacy::Accreditation
  attr_accessor :address
  attr_reader :phones

  def <=>(other)
    order <=> other.order
  end

  def hidden?
    @prefs.present? and @prefs.hidden?
  end

  def visible?
    !hidden?
  end

  def phones=(o)
    @phones = o.sort
  end

  attr_writer :prefs

  def order
    @prefs.present? ? @prefs.order : super
  end

  def visible_phones
    @phones.select { |p| p.visible? }.sort # .map{|p| p.phone}
  end

  def phone
    @phones.present? ? @phones.sort.first : nil
  end

  # def room
  #   @phones.present? ? @phones.local : nil
  # end
end
