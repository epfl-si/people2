class Legacy::Person < Legacy::BaseDinfo
  self.table_name = 'sciper'
  self.primary_key = 'sciper'

  has_one  :email, :class_name => "Email", :foreign_key => "sciper"

  # has_many :active_accreds, -> { 
  #   where("#{Legacy::Accreditation.table_name}.finval IS NULL OR #{Legacy::Accreditation.table_name}.finval > ?", Date.today.strftime).
  #   order(:ordre).
  #   joins(:status).
  #   joins("LEFT OUTER JOIN classes ON classes.id = accreds.classid"). 
  #   joins("LEFT OUTER JOIN positions ON positions.id = accreds.posid")
  # }, :class_name => "Accreditation", :foreign_key => "persid"
  # in the end the following is faster and easier
  has_many :active_accreds, -> {
    includes(:status, :kind, :position).
    where("#{Legacy::Accreditation.table_name}.finval IS NULL OR #{Legacy::Accreditation.table_name}.finval > ?", Date.today.strftime).
    order(:ordre)
  }, :class_name => "Accreditation", :foreign_key => "persid"
  has_many :active_units, :class_name => "Unit", :through => :active_accreds, :foreign_key => "persid", :source => "unit"
  has_many :active_positions, :class_name => "Position", :through => :active_accreds, :foreign_key => "persid", :source => "position"

  has_many :policies, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_policies, -> { where("#{Legacy::Policy.table_name}.finval IS NULL OR #{Legacy::Policy.table_name}.finval > ?", Date.today.strftime) }, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_properties, :class_name => "Property", :through => :active_policies, :foreign_key => "persid", :source => "property"

  has_many :accred_prefs, :class_name => "AccredPref", :foreign_key => "sciper"
  has_one :account, :class_name => "Account", :foreign_key => "sciper"

  # default_scope { includes(:author).order('created_at ASC') }

  def affiliations
    active_accreds.map{|a| Legacy::Affiliation.new(a, atela.accreds[a.unitid], sex)}
  end

  def atela
    @atela ||= Atela::Person.new(self.sciper)
  end
# # {
#   "address"=>{
#     "adr"=>"EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne", 
#     "cmd_id"=>796438, 
#     "line1"=>"EPFL SI IDEV-FSD", 
#     "line2"=>"INN 012 (Bâtiment INN)", 
#     "line3"=>"Station 14", 
#     "line4"=>"CH-1015 Lausanne", 
#     "line5"=>"", 
#     "pays"=>"Suisse", 
#     "pers_id"=>121769, 
#     "room_unit_id"=>"", 
#     "type"=>"custom", 
#     "type_related_id"=>"0", 
#     "unit_id"=>13030, 
#     "valid_from"=>"2021-08-11 09:13:17", 
#     "valid_to"=>"", 
#     "value"=>"EPFL SI IDEV-FSD $ INN 012 (Bâtiment INN) $ Station 14 $ CH-1015 Lausanne"
#   }, 
#   "hierarchie"=>"EPFL VPO-SI ISAS ISAS-FSD", 
#   "ordre"=>1, 
#   "phones"=>[
#     {
#       "from_default"=>"true", 
#       "other_room"=>"", 
#       "outgoing_right"=>"NATIONAL", 
#       "phone_hidden"=>"0", 
#       "phone_id"=>3971, 
#       "phone_nb"=>"+41216937526", 
#       "phone_order"=>1, 
#       "phone_type"=>"FIXE_OFFICE", 
#       "room_id"=>""
#     }
#   ], 
#   "rooms"=>[
#     {
#       "description"=>"Bureau", 
#       "from_default"=>"true", 
#       "room_abr"=>"INN 014", 
#       "room_hidden"=>"0", 
#       "room_id"=>31559, 
#       "room_order"=>1, 
#       "type"=>"internal"
#     }
#   ], 
#   "sigle"=>"ISAS-FSD"
# }

  def contact(unit_id)

  end

  def birthday
    self.date_naiss
  end

  def can_edit_profile?
    self.active_accreds.any? {|a| a.can_edit_profile?} ||
      self.active_properties.map{|p| p.id}.include?(7) ||
        self.active_positions.map{|p| p.labelfr}.include?('Professeur honoraire')
  end

  # $is_achieving_professor = $ENV{FORCE_ACHIEVING_PROF} || does_have_right_anywhere($self, $sciper, 'AAR.report.control');
  # sub does_have_right_anywhere {
  #   my ($self, $sciper, $right_name) = @_;
  #   return unless $sciper;

  #   see common-libs/accred-libs/Accred/Rights.pm
  #   my $rup = $self->{Rights}->getRights (
  #     persid => $sciper,
  #     rightid => $right_name,
  #   );
  #   if (keys %{$rup}) {
  #     return 1;
  #   } else {
  #     return 0;
  #   }
  # }  
  # TODO implement Rights model
  def is_achieving_professor?
    true
  end


  def display_name
    @display_name ||= "#{self.prenom_usuel || self.prenom_acc} #{self.nom_usuel || self.nom_acc}"
  end

  def email_address
    self.email.addrlog
  end

  def phone
    atela.phone
  end

  def room 
    atela.room
  end

  def sex
    self.sexe
  end

  def gender
    self.sexe == "F" ? "female" : "male"
  end

  def units
    self.accreditations.map{|a| a.unit }
  end

  def username
    atela.username
  end

  def visible_units
    self.accreditations.select{|a| a.accred_show == "1"}.map{|a| a.unit }
  end

  def solved_accreds
    active_accreds.map do |a|

    end
  end

# dinfo
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

# accred
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


end


# ItemToSku.joins("LEFT JOIN inventory ON item_to_sku.sku_id = inventory.sku_id").where("item_id in (?)", [12345, 67890])

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
