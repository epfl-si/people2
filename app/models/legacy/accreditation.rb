# accred part of getAllAccredsSolved
#       accreds.*,
#       statuses.`name`         AS statusname,
#       statuses.labelfr        AS statuslabelfr,
#       statuses.labelen        AS statuslabelen,
#       classes.`name`          AS classname,
#       classes.labelfr         AS classlabelfr,
#       classes.labelen         AS classlabelen,
#       positions.labelfr       AS poslabelfr,
#       positions.labelen       AS poslabelen,
#       positions.labelxx       AS poslabelxx

# persid  unitid statusid classid posid
# 363674  50133         5      21  NULL
# 363674  50133         5      15  NULL
# 363674  50099         5      21  NULL
# 363674  50099         5      15  NULL
# 363674  50099         5      15  NULL
# 363674  50133         5      15  NULL


class Legacy::Accreditation < Legacy::BaseAccred
  self.table_name = 'accreds'
  self.primary_key = 'persid'
  belongs_to :person, :class_name => "Person", :foreign_key => "persid", :inverse_of => :accreds
  belongs_to :unit, :class_name => "Unit", :foreign_key => "unitid"
  belongs_to :position, :class_name => "Position", :foreign_key => "posid"
  belongs_to :status, :class_name => "Status", :foreign_key => "statusid"
  belongs_to :kind, :class_name => "PersonClass", :foreign_key => "classid"

  default_scope {
    joins(:position, :status, :kind).includes(:unit).where(finval: nil)
  }

  # TODO: these arrays could become obsolete if server never reloads
  def self.can_edit_profile_with_given_accred?(a)
    @can_edit_position_ids ||= Legacy::Position.where(labelfr: 'Professeur honoraire').map{|p| p.id}
    @can_edit_status_ids ||= Legacy::Status.where(labelen: ['Staff', 'Student']).map{|s| s.id}
    @can_edit_status_ids.include?(a.statusid) or @can_edit_position_ids.include?(a.posid)
  end
  def self.is_student_with_given_accred?(a)
    @student_status_ids ||= Legacy::Status.where(labelen: ['Student', 'External student']).map{|s| s.id}
    @student_status_ids.include?(a.statusid)
  end

  def unit_id
    self.unitid
  end

  def sciper
    self.persid
  end

  def order
    self.ordre
  end

  def can_edit_profile?
    Legacy::Accreditation.can_edit_profile_with_given_accred?(self)
  end

  def is_student?
    Legacy::Accreditation.is_student_with_given_accred?(self)
  end

  # TODO: possibly move this to a Presenter or Decorator class (see patterns)
  def t_position(lang=I18n.locale)
    gender = self.person.gender
    tablegender = gender == "female" ? "xx" : lang
    if self.position.nil?
      I18n.t "student.#{gender}"
    else
      self.position["label#{tablegender}"]
    end
  end

  def hierarchy
    self.unit.present? ? self.unit.hierarchie : nil
  end

  def class_delegate
    se, pe = self.unit.sigle.split("-")
    d = self.person.delegate
    if d.nil? or d.section != se or d.periode != pe
      return nil
    else
      return d
    end
  end
end

# sub getAllAccredsSolved {
#   my ($self, $type, $val) = @_;
#   my $persid = $val if $type eq 'persid';
#   my $unitid = $val if $type eq 'unitid';
#   #FIXME if there's a typo in type the method will return the whole consolidated table and it will take a loooooong time
#   my $sql = qq{
#     SELECT
#       accreds.*,
#       dinfo.sciper.nom_acc,      dinfo.sciper.nom_usuel,
#       dinfo.sciper.prenom_acc,   dinfo.sciper.prenom_usuel, dinfo.sciper.sexe,
#       dinfo.allunits.sigle,      dinfo.allunits.libelle, dinfo.allunits.libelle_en,
#       dinfo.allunits.hierarchie,
#       dinfo.groups.gid,
#       dinfo.annu.`local`            AS room,
#       dinfo.annu.telephone1,
#       dinfo.annu.telephone2,
#       dinfo.adrspost.adresse  AS address,
#       dinfo.adrspost.ordre    AS address_ordre,
#       statuses.`name`         AS statusname,
#       statuses.labelfr        AS statuslabelfr,
#       statuses.labelen        AS statuslabelen,
#       classes.`name`          AS classname,
#       classes.labelfr         AS classlabelfr,
#       classes.labelen         AS classlabelen,
#       positions.labelfr       AS poslabelfr,
#       positions.labelen       AS poslabelen,
#       positions.labelxx       AS poslabelxx
#     FROM
#       accreds
#       INNER JOIN dinfo.sciper        ON      dinfo.sciper.sciper = accreds.persid
#       INNER JOIN dinfo.allunits      ON  dinfo.allunits.id_unite = accreds.unitid
#       INNER JOIN dinfo.groups        ON          dinfo.groups.id = accreds.unitid
#       INNER JOIN statuses            ON              statuses.id = accreds.statusid
#       LEFT OUTER JOIN classes        ON               classes.id = accreds.classid
#       LEFT OUTER JOIN positions      ON             positions.id = accreds.posid
#       LEFT OUTER JOIN dinfo.annu     ON (dinfo.annu.sciper = accreds.persid AND dinfo.annu.unite = accreds.unitid)
#       LEFT OUTER JOIN dinfo.adrspost ON (dinfo.adrspost.sciper = accreds.persid AND dinfo.adrspost.unite = accreds.unitid)
#   };
#   my ($debcond, $fincond, @dateconds);
#   $debcond = "(accreds.debval is NULL or accreds.debval <= now())";
#   $fincond = "(accreds.finval is NULL or accreds.finval  > now())";
#   $sql .= qq{
#      where $debcond
#        and $fincond
#   };
#   my @args;
#   if ($persid) {
#     $sql .= ' and accreds.persid = ?';
#     @args = $persid;
#   }

#   if ($unitid) {
#       if (ref $unitid eq 'ARRAY') {
#           $sql .= ' and (0 ';
#           foreach my $uid (@{$unitid}) {
#               $sql .= 'OR ? IN (dinfo.allunits.level1, dinfo.allunits.level2, dinfo.allunits.level3, dinfo.allunits.level4)';
#               push @args, $uid;
#           }
#           $sql .= ')';
#       }
#       else {
#           $sql .= ' and ? IN (dinfo.allunits.level1, dinfo.allunits.level2, dinfo.allunits.level3, dinfo.allunits.level4)';
#           @args = $unitid;
#       }
#   }

#   #warn "sql=$sql";
#   my $cadidb = $self->{cadidb};
#   my $sth = $cadidb->prepare ($sql);
#   unless ($sth) {
#     $self->{errmsg} = "getAccreds : $cadidb->{errmsg}";
#     return;
#   }
#   my $rv = $cadidb->execute ($sth, @args, @dateconds);
#   unless ($rv) {
#     $self->{errmsg} = "getAccreds : $cadidb->{errmsg}";
#     return;
#   }

#   my @accreds;
#   while (my $accred = $sth->fetchrow_hashref) {
#     $accred->{person} = {
#          id => $accred->{persid},
#        name => $accred->{nom_usuel}    || $accred->{nom_acc},
#       fname => $accred->{prenom_usuel} || $accred->{prenom_acc},
#        sexe => $accred->{sexe},
#     };
#     delete $accred->{nom_usuel};
#     delete $accred->{nom_acc};
#     delete $accred->{prenom_usuel};
#     delete $accred->{prenom_acc};
#     delete $accred->{sexe};

#     $accred->{unit} = {
#          id => $accred->{unitid},
#       sigle => $accred->{sigle},
#       label => $accred->{libelle},
#     labelen => $accred->{libelle_en},
#        path => $accred->{hierarchie},
#         gid => $accred->{gid},
#     };
#     delete $accred->{sigle};
#     delete $accred->{libelle};
#     delete $accred->{hierarchie};
#     delete $accred->{gid};

#     $accred->{status} = {
#            id => $accred->{statusid},
#          name => $accred->{statusname},
#       labelfr => $accred->{statuslabelfr},
#       labelen => $accred->{statuslabelen},
#     };
#     delete $accred->{statusname};
#     delete $accred->{statuslabelfr};
#     delete $accred->{statuslabelen};

#     $accred->{class} = {
#            id => $accred->{classid},
#          name => $accred->{classname},
#       labelfr => $accred->{classlabelfr},
#       labelen => $accred->{classlabelen},
#     };
#     delete $accred->{classname};
#     delete $accred->{classlabelfr};
#     delete $accred->{classlabelen};

#      $accred->{position} = {
#            id => $accred->{posid},
#          name => $accred->{posname},
#       labelfr => $accred->{poslabelfr},
#       labelen => $accred->{poslabelen},
#       labelxx => $accred->{poslabelxx},
#     };
#     delete $accred->{posname};
#     delete $accred->{poslabelfr};
#     delete $accred->{poslabelen};
#     # FIXME: delete $accred->{poslabelxx}; ?

#     $accred->{annu} = {
#          room => $accred->{room},
#        phones => [ $accred->{telephone1}, $accred->{telephone2}, ],
#     };
#     delete $accred->{room};
#     delete $accred->{telephone1};
#     delete $accred->{telephone2};

#     $accred->{address} = {
#       address => $accred->{address},
#         ordre => $accred->{address_ordre},
#     };
#     delete $accred->{address_ordre};

#     push (@accreds, $accred);
#   }

#   return @accreds;
# }

