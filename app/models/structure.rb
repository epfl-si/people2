# frozen_string_literal: true

class Structure < ApplicationRecord
  serialize :data, coder: JSON
  validates :label, uniqueness: true
  validate :check_sections_count_match

  def self.load(label, lang = 'en')
    if ["1", 1].include?(label)
      label = lang == 'en' ? "default_en_struct" : "default_struct"
    end
    where(label: label).first
  end

  def sections
    @sections ||= data.map do |d|
      f = PositionFilter.new(d["filter"])
      OpenStruct.new(title: d["title"], filter: f, items: []) if f.valid?
    end.compact
  end

  def check_sections_count_match
    return if sections.count == data.count

    errors.add(:data, "sections count does not match data entries")
  end

  def store(person)
    sections.each do |f|
      if person.match_position_filter?(f.filter)
        f.items << person
        return true
      end
    end
    false
  end

  # In this case, in order to reproduce the original behaviour, we rewrite the
  # accreditations so that we only keep the one that matches.
  def store!(person)
    sections.each do |f|
      next unless person.match_position_filter?(f.filter)

      person.select_positions!(f.filter) unless f.filter.catch_all?
      f.items << person
      return true
    end
    false
  end
end

#-------------------------------------------------------------- original sources
# getAllAccredsSolved returns consilidated accreds in no explicit order
# $accreds = $units ? getUnitsAccreds ($units) : getScipersAccreds ($scipers);
# In getUnitsAccreds:
# foreach my $unit_id (keys %$unit_ids) {
#   foreach my $accred ( $Accreds->getAllAccredsSolved('unitid', $unit_id) ) {
#     next unless $Accreds->getAccredProperty ($accred, $visibiliteweb);
#     ...
#     my $person = $accred->{person};
#     my $grp = getFunctGroup($accred->{position}->{labelfr});
#     push @{$groups_array->{$grouplabels[$grp]}}, {
#       sciper => $person->{id},
#       nom    => $person->{name},
#       prenom => $person->{fname},
#       ...
#     };

# Struct file reader stores $maxgroups labels and lists of functions
# in @grouplabels and @groupfuncts respectively. Therefore, this finds the index
# of the index of the first group that matches the person position $func
#
# sub getFunctGroup {
#   my ($func) = @_;
#    for (my $i = 0; $i < $maxgroups; $i++) {
#      foreach my $group_func (split (/,/, $groupfuncts[$i])) {
#        if ($group_func =~/\*/) {
#         $group_func =~ s/\*//g;
#         if ($func =~ /^$group_func/i) {
#           return $i ;
#         }
#        } else {
#         if ($func =~ /^$group_func$/i) {
#           return $i ;
#         }
#        }
#      }
#    }
#    return $maxgroups;
# }
